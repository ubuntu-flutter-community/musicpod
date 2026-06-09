import 'dart:io';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/logging.dart';
import '../../common/persistence/database.dart';
import '../../extensions/date_time_x.dart';

@lazySingleton
class PodcastDao {
  final Database _db;

  PodcastDao({required Database db}) : _db = db;

  Future<bool> hasPodcastStoredEpisodes(String feedUrl) async {
    final count =
        await (_db.selectOnly(_db.podcastEpisodeTable)
              ..addColumns([_db.podcastEpisodeTable.contentUrl])
              ..where(_db.podcastEpisodeTable.podcastFeedUrl.equals(feedUrl)))
            .get()
            .then((rows) => rows.length);
    return count > 0;
  }

  Future<List<Audio>> getEpisodes(String feedUrl) async {
    // Load episodes from DB WITHOUT loading the feed from the internet
    final rows = await (_db.select(
      _db.podcastEpisodeTable,
    )..where((t) => t.podcastFeedUrl.equals(feedUrl))).get();
    return rows
        .map((r) => getEpisodeFromTableEntry(r, feedUrl: feedUrl))
        .toSet()
        .toList();
  }

  Map<String, PodcastTableData> _podcastCache = {};

  Audio getEpisodeFromTableEntry(
    PodcastEpisodeTableData data, {
    required String feedUrl,
  }) {
    // find podcast table data first:
    final podcastData = _podcastCache[feedUrl];

    return Audio(
      url: data.contentUrl,
      title: data.title,
      podcastTitle: podcastData?.name,
      episodeDescription: data.episodeDescription,
      podcastDescription: data.podcastDescription,
      publicationDate: data.publicationDate.millisecondsSinceEpoch,
      durationMs: data.durationMs?.toDouble(),
      imageUrl: podcastData?.imageUrl ?? data.imageUrl,
      albumArtUrl: podcastData?.imageUrl ?? data.imageUrl,
      feedUrl: feedUrl,
      audioType: AudioType.podcast,
      copyright: podcastData?.artist,
    );
  }

  Future<void> upsertEpisodes({
    required String feedUrl,
    required String? podcastDescription,
    required List<Audio> episodes,
  }) async {
    if (episodes.isEmpty) return;

    await _db.batch((batch) {
      for (final e in episodes) {
        if (e.url == null) continue;
        batch.insert(
          _db.podcastEpisodeTable,
          PodcastEpisodeTableCompanion.insert(
            podcastFeedUrl: feedUrl,
            title: e.title ?? '',
            episodeDescription: e.episodeDescription ?? '',
            podcastDescription: podcastDescription ?? '',
            contentUrl: e.url!,
            publicationDate: e.publicationDate != null
                ? DateTime.fromMillisecondsSinceEpoch(e.publicationDate!)
                : DateTime.now(),
            durationMs: Value(e.durationMs?.toInt()),
            imageUrl: Value(e.imageUrl),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<Set<String>> getStoredEpisodeUrls(String feedUrl) async {
    final rows =
        await (_db.selectOnly(_db.podcastEpisodeTable)
              ..addColumns([_db.podcastEpisodeTable.contentUrl])
              ..where(_db.podcastEpisodeTable.podcastFeedUrl.equals(feedUrl)))
            .get();
    return rows
        .map((r) => r.read(_db.podcastEpisodeTable.contentUrl))
        .whereType<String>()
        .toSet();
  }

  Future<
    ({Map<String, String> downloadFilePaths, Set<String> feedsWithDownloads})
  >
  getDownloads() async {
    final rows = await _db.select(_db.downloadTable).get();
    final downloadedFilePaths = {for (final r in rows) r.url: r.filePath};
    final feedsWithDownloads = rows.map((r) => r.feedUrl).toSet();
    return (
      downloadFilePaths: downloadedFilePaths,
      feedsWithDownloads: feedsWithDownloads,
    );
  }

  Future<
    ({
      Map<String, String> newDownloadFilePaths,
      Set<String> newFeedsWithDownloads,
    })
  >
  cleanUpDownloadMismatches({
    required Map<String, String> downloadFilePaths,
    required Set<String> feedsWithDownloads,
    required String? downloadsDir,
  }) async {
    final newDownloadFilePaths = Map<String, String>.from(downloadFilePaths);
    var newFeedsWithDownloads = Set<String>.from(feedsWithDownloads);

    final rows = await _db.select(_db.downloadTable).get();
    final nonExisting = <DownloadTableData>[];
    for (final entry in rows) {
      if (!File(entry.filePath).existsSync()) {
        printInfoInDebugMode(
          'Cleaning non-existing download:  [${entry.filePath} for URL: ${entry.url}]',
          tag: '$PodcastDao',
        );
        nonExisting.add(entry);
      }
    }

    if (nonExisting.isNotEmpty) {
      final urlsToDelete = nonExisting.map((e) => e.url).toList();
      await (_db.delete(
        _db.downloadTable,
      )..where((t) => t.url.isIn(urlsToDelete))).go();
      for (final entry in nonExisting) {
        newDownloadFilePaths.remove(entry.url);
      }

      final remainingRows = rows
          .where((r) => !urlsToDelete.contains(r.url))
          .toList();
      newFeedsWithDownloads = remainingRows.map((r) => r.feedUrl).toSet();
    }

    final realDownloadFilePaths = downloadsDir != null
        ? Directory(
            downloadsDir,
          ).listSync().whereType<File>().map((f) => f.path).toSet()
        : <String>{};

    // delete files that do not have a corresponding entry in the database
    for (final filePath in realDownloadFilePaths) {
      if (!newDownloadFilePaths.containsValue(filePath)) {
        printInfoInDebugMode(
          'Deleting file without database entry: $filePath',
          tag: '$PodcastDao',
        );
        try {
          File(filePath).deleteSync();
        } on Exception catch (e, s) {
          printErrorInDebugMode(e, trace: s, tag: '$PodcastDao');
          rethrow;
        }
      }
    }
    return (
      newDownloadFilePaths: newDownloadFilePaths,
      newFeedsWithDownloads: newFeedsWithDownloads,
    );
  }

  Future<void> addDownload({
    required String url,
    required String path,
    required String feedUrl,
  }) => _db
      .into(_db.downloadTable)
      .insert(
        DownloadTableCompanion.insert(
          url: url,
          filePath: path,
          feedUrl: feedUrl,
        ),
        mode: InsertMode.insertOrReplace,
      );

  Future<void> deleteDownload(List<String> urls) =>
      (_db.delete(_db.downloadTable)..where((t) => t.url.isIn(urls))).go();

  Future<void> deleteDownloads() => _db.delete(_db.downloadTable).go();

  Future<Set<String>> getPodcasts() async {
    final rows = await (_db.select(
      _db.podcastTable,
    )..orderBy([(t) => OrderingTerm(expression: t.name)])).get();
    _podcastCache = {for (final r in rows) r.feedUrl: r};
    return rows.map((r) => r.feedUrl).toSet();
  }

  String? getPodcastImage(String feedUrl) => _podcastCache[feedUrl]?.imageUrl;

  void updatePodcastImage({
    required String feedUrl,
    required String imageUrl,
    required String title,
  }) {
    (_db.update(_db.podcastTable)..where((t) => t.feedUrl.equals(feedUrl)))
        .write(
          PodcastTableCompanion(imageUrl: Value(imageUrl), name: Value(title)),
        )
        .then((_) {
          final cached = _podcastCache[feedUrl];
          if (cached != null) {
            _podcastCache[feedUrl] = cached.copyWith(
              imageUrl: Value(imageUrl),
              name: title,
            );
          }
        });
  }

  String? getPodcastName(String feedUrl) => _podcastCache[feedUrl]?.name;

  String? getPodcastArtist(String feedUrl) => _podcastCache[feedUrl]?.artist;

  Future<void> addPodcast({
    required String feedUrl,
    required String? imageUrl,
    required String name,
    required String artist,
  }) async {
    final now = DateTime.now();
    await _db
        .into(_db.podcastTable)
        .insert(
          PodcastTableCompanion.insert(
            feedUrl: feedUrl,
            name: name,
            artist: artist,
            description: '',
            imageUrl: Value(imageUrl),
            lastUpdated: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    _podcastCache[feedUrl] = PodcastTableData(
      feedUrl: feedUrl,
      name: name,
      artist: artist,
      description: '',
      imageUrl: imageUrl,
      lastUpdated: now,
      ascending: false,
    );
  }

  Future<void> addPodcasts(
    List<({String feedUrl, String? imageUrl, String name, String artist})>
    newPodcasts,
  ) async {
    if (newPodcasts.isEmpty) return;

    final now = DateTime.now();
    await _db.batch((batch) {
      for (final p in newPodcasts) {
        batch.insert(
          _db.podcastTable,
          PodcastTableCompanion.insert(
            feedUrl: p.feedUrl,
            name: p.name,
            artist: p.artist,
            description: '',
            imageUrl: Value(p.imageUrl),
            lastUpdated: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });

    for (final p in newPodcasts) {
      _podcastCache[p.feedUrl] = PodcastTableData(
        feedUrl: p.feedUrl,
        name: p.name,
        artist: p.artist,
        description: '',
        imageUrl: p.imageUrl,
        lastUpdated: now,
        ascending: false,
      );
    }
  }

  Future<void> reorderPodcast({
    required String feedUrl,
    required bool ascending,
  }) async {
    await (_db.update(_db.podcastTable)
          ..where((t) => t.feedUrl.equals(feedUrl)))
        .write(PodcastTableCompanion(ascending: Value(ascending)));
    final cached = _podcastCache[feedUrl];
    if (cached != null) {
      _podcastCache[feedUrl] = cached.copyWith(ascending: ascending);
    }
  }

  Set<String> get ascendingPodcasts => _podcastCache.values
      .where((p) => p.ascending == true)
      .map((p) => p.feedUrl)
      .toSet();

  Future<Set<String>> getPodcastUpdates() async {
    final rows = await _db.select(_db.podcastUpdateTable).get();
    return rows.map((r) => r.podcastFeedUrl).toSet();
  }

  Future<void> addPodcastLastUpdated({
    required String feedUrl,
    required DateTime lastUpdated,
  }) async {
    await (_db.update(_db.podcastTable)
          ..where((t) => t.feedUrl.equals(feedUrl)))
        .write(PodcastTableCompanion(lastUpdated: Value(lastUpdated)));
    final cached = _podcastCache[feedUrl];
    if (cached != null) {
      _podcastCache[feedUrl] = cached.copyWith(lastUpdated: lastUpdated);
    }
  }

  String? getPodcastLastUpdated(String feedUrl) =>
      _podcastCache[feedUrl]?.lastUpdated.toPodcastTimeStamp;

  Future<void> addPodcastUpdate(String feedUrl) async {
    await _db
        .into(_db.podcastUpdateTable)
        .insert(
          PodcastUpdateTableCompanion.insert(podcastFeedUrl: feedUrl),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> deletePodcastUpdate(String feedUrl) => (_db.delete(
    _db.podcastUpdateTable,
  )..where((t) => t.podcastFeedUrl.equals(feedUrl))).go();

  Future<Set<String>> deleteOrphanEpisodes() async {
    // Create the base query with the join
    final query = _db.selectOnly(_db.podcastEpisodeTable).join([
      leftOuterJoin(
        _db.podcastTable,
        _db.podcastTable.feedUrl.equalsExp(
          _db.podcastEpisodeTable.podcastFeedUrl,
        ),
      ),
    ]);

    // Explicitly tell Drift what column to SELECT
    query.addColumns([_db.podcastEpisodeTable.podcastFeedUrl]);

    // Filter for orphaned rows
    query.where(_db.podcastTable.feedUrl.isNull());

    // Fetch the data
    final List<TypedResult> rows = await query.get();

    final Set<String> feedUrlsToDelete = rows
        .map((r) => r.read(_db.podcastEpisodeTable.podcastFeedUrl))
        .whereType<String>()
        .toSet();

    // Early exit if nothing to delete
    if (feedUrlsToDelete.isEmpty) {
      printInfoInDebugMode(
        'No orphaned episodes found to clean up.',
        tag: '$PodcastDao',
      );
      return <String>{};
    }

    // Delete the orphaned episodes
    printInfoInDebugMode(
      'Deleting episodes with feed URLs not in podcast table: $feedUrlsToDelete',
      tag: '$PodcastDao',
    );

    await (_db.delete(
      _db.podcastEpisodeTable,
    )..where((tbl) => tbl.podcastFeedUrl.isIn(feedUrlsToDelete))).go();

    return feedUrlsToDelete;
  }

  Future<void> deletePodcastAndFriends({
    required Set<String> deleteMeUrls,
  }) async {
    await _db.transaction(() async {
      await _db.batch((batch) {
        batch.deleteWhere(
          _db.podcastEpisodeTable,
          (t) => t.podcastFeedUrl.isIn(deleteMeUrls.toList()),
        );
        batch.deleteWhere(
          _db.podcastUpdateTable,
          (t) => t.podcastFeedUrl.isIn(deleteMeUrls.toList()),
        );
        batch.deleteWhere(
          _db.downloadTable,
          (t) => t.feedUrl.isIn(deleteMeUrls.toList()),
        );
        batch.deleteWhere(
          _db.podcastTable,
          (t) => t.feedUrl.isIn(deleteMeUrls.toList()),
        );
      });
    });

    if (deleteMeUrls.isNotEmpty) {
      await _db.reclaimDiskSpace();
    }
  }

  Future<Set<String>> _existingTableNames() async {
    final rows = await _db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }

  Future<void> deleteAllPodcasts() async {
    final existingTables = await _existingTableNames();

    final tables = <TableInfo>[
      _db.podcastEpisodeTable,
      _db.podcastUpdateTable,
      _db.downloadTable,
      _db.podcastTable,
      _db.podcastGenreRelationTable,
      _db.podcastGenreTable,
    ].where((t) => existingTables.contains(t.actualTableName)).toList();

    await _db.transaction(() async {
      await _db.batch((batch) {
        for (final table in tables) {
          batch.deleteAll(table);
        }
      });
    });
    await _db.reclaimDiskSpace();
  }

  Future<void> updateAudioDuration(Audio audio) async {
    await (_db.update(
      _db.podcastEpisodeTable,
    )..where((t) => t.contentUrl.equals(audio.url ?? ''))).write(
      PodcastEpisodeTableCompanion(
        durationMs: Value(audio.durationMs?.toInt()),
      ),
    );
  }

  Future<void> insertPodcastGenre({
    required String feedUrl,
    required String genreName,
  }) async {
    printInfoInDebugMode(
      'Upserting genre "$genreName" for feedUrl: $feedUrl',
      tag: '$PodcastDao',
    );
    await _db.transaction(() async {
      final cleanName = genreName.trim();
      int genreId;

      // 1. Check if this genre name already exists in the master table
      final existingGenre = await (_db.select(
        _db.podcastGenreTable,
      )..where((t) => t.name.equals(cleanName))).getSingleOrNull();

      if (existingGenre != null) {
        genreId = existingGenre.id;
      } else {
        // 2. If it doesn't exist, insert it.
        // Drift returns the newly generated auto-incremented ID.
        genreId = await _db
            .into(_db.podcastGenreTable)
            .insert(PodcastGenreTableCompanion.insert(name: cleanName));
      }

      // 3. Link the podcast feed to this genre ID
      await _db
          .into(_db.podcastGenreRelationTable)
          .insertOnConflictUpdate(
            PodcastGenreRelationTableCompanion.insert(
              feedUrl: feedUrl,
              genreId: genreId
                  .toString(), // Cast to String if relation table still expects a text ID
            ),
          );
    });
  }

  Future<String?> getPodcastGenre(String feedUrl) async {
    // The query structure remains almost identical, but Drift handles
    // the underlying SQLite type conversion automatically.
    final query = _db.select(_db.podcastGenreRelationTable).join([
      innerJoin(
        _db.podcastGenreTable,
        // If your relation table's genreId is now an integer, use .equalsExp() directly.
        // If it's still a string, you may need to cast using .cast<String>() depending on your setup.
        _db.podcastGenreTable.id.cast<String>().equalsExp(
          _db.podcastGenreRelationTable.genreId,
        ),
      ),
    ])..where(_db.podcastGenreRelationTable.feedUrl.equals(feedUrl));

    query.limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    return row.readTable(_db.podcastGenreTable).name;
  }
}
