import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:podcast_search/podcast_search.dart' hide Value;
import 'package:synchronized/synchronized.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import '../common/persistence/database.dart';
import '../common/view/audio_filter.dart';
import '../common/view/languages.dart';
import '../extensions/date_time_x.dart';
import '../extensions/string_x.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
import 'data/podcast_genre.dart';

@lazySingleton
class PodcastService {
  final SettingsService _settingsService;
  final Database _db;
  final Dio _dio;

  PodcastService({
    required SettingsService settingsService,
    required Database database,
    required Dio dio,
  }) : _settingsService = settingsService,
       _db = database,
       _dio = dio {
    _search = Search(
      searchProvider:
          _settingsService.getBool(SPKeys.usePodcastIndex) == true &&
              _settingsService.getString(SPKeys.podcastIndexApiKey) != null &&
              _settingsService.getString(SPKeys.podcastIndexApiSecret) != null
          ? PodcastIndexProvider(
              key: _settingsService.getString(SPKeys.podcastIndexApiKey)!,
              secret: _settingsService.getString(SPKeys.podcastIndexApiSecret)!,
            )
          : const ITunesProvider(),
    );
  }

  SearchResult? _searchResult;
  late Search _search;

  SearchProvider initSearchProvider({bool forceInit = false}) {
    if (forceInit) {
      _search = Search(
        searchProvider:
            _settingsService.getBool(SPKeys.usePodcastIndex) == true &&
                _settingsService.getString(SPKeys.podcastIndexApiKey) != null &&
                _settingsService.getString(SPKeys.podcastIndexApiSecret) != null
            ? PodcastIndexProvider(
                key: _settingsService.getString(SPKeys.podcastIndexApiKey)!,
                secret: _settingsService.getString(
                  SPKeys.podcastIndexApiSecret,
                )!,
              )
            : const ITunesProvider(),
      );
    }
    return _search.searchProvider;
  }

  List<PodcastGenre> get cachedPodcastGenres => _podcastGenreCache;
  List<PodcastGenre> _podcastGenreCache = [];
  Future<List<PodcastGenre>> loadGenres({bool force = false}) async {
    if (_podcastGenreCache.isNotEmpty && !force) {
      return _podcastGenreCache;
    }

    var genres = <String>{};
    try {
      genres = await _search.genres().toSet();
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }

    _podcastGenreCache = genres
        .map((g) => PodcastGenre.fromString(g))
        .toSet()
        .toList();

    return _podcastGenreCache;
  }

  String? _previousQuery;
  Future<SearchResult?> search({
    String? searchQuery,
    PodcastGenre podcastGenre = PodcastGenre.all,
    Country? country,
    SimpleLanguage? language,
    int limit = 10,
    Attribute attribute = Attribute.none,
  }) async {
    SearchResult? result;
    try {
      if (searchQuery == null || searchQuery.isEmpty == true) {
        result = await _search.charts(
          genre: podcastGenre == PodcastGenre.all ? '' : podcastGenre.id,
          limit: limit,
          country: country ?? Country.none,
          language: country != null || language?.isoCode == null
              ? ''
              : language!.isoCode,
        );
      } else {
        result = await _search.search(
          searchQuery,
          country: country ?? Country.none,
          language: country != null || language?.isoCode == null
              ? ''
              : language!.isoCode,
          limit: limit,
          attribute: attribute,
        );
      }
    } catch (e) {
      printMessageInDebugMode('Podcast search error: $e');
      rethrow;
    }

    printMessageInDebugMode(
      'Podcast search result: successful=${result.successful}, '
      'itemCount=${result.items.length}, '
      'query=$searchQuery',
    );

    if (!result.successful) {
      throw result.lastError;
    }

    if (result.successful &&
        (searchQuery == null ||
            _previousQuery != searchQuery ||
            (_previousQuery == searchQuery &&
                _searchResult?.items.isNotEmpty == true))) {
      _searchResult = result;
    }
    _previousQuery = searchQuery;

    return _searchResult;
  }

  final _syncLock = Lock();
  Future<Set<String>> checkForUpdates({
    required Iterable<String> feedUrls,
    void Function(double progress)? updateProgress,
  }) => _syncLock.synchronized(
    () => _checkForUpdates(
      toCheckFeedUrls: feedUrls.isEmpty ? podcastFeedUrls : feedUrls,
      updateProgress: updateProgress,
    ),
  );

  Future<Set<String>> _checkForUpdates({
    required Iterable<String> toCheckFeedUrls,
    void Function(double progress)? updateProgress,
  }) async {
    await loadPodcastUpdatesFromDb();

    for (final (index, feedUrl) in toCheckFeedUrls.indexed) {
      final storedTimeStamp = getPodcastLastUpdated(feedUrl);
      final name = getSubscribedPodcastName(feedUrl);

      printMessageInDebugMode('checking update for: ${name ?? feedUrl} ');
      printMessageInDebugMode(
        'storedTimeStamp: ${storedTimeStamp ?? 'no timestamp stored'}',
      );

      DateTime? feedLastUpdated;
      try {
        feedLastUpdated = await Feed.feedLastUpdated(url: feedUrl);
      } on Exception catch (e) {
        printMessageInDebugMode(e);
      }

      printMessageInDebugMode(
        'feedLastUpdated: ${feedLastUpdated?.toPodcastTimeStamp ?? 'Feed did not set "lastUpdated"'}',
      );

      if (feedLastUpdated == null) continue;

      if (!storedTimeStamp.isSamePodcastTimeStamp(feedLastUpdated)) {
        await _addPodcastLastUpdated(
          feedUrl: feedUrl,
          lastUpdated: feedLastUpdated,
        );

        // Compare actual episode URLs to detect genuinely new episodes,
        // since Last-Modified can change without new episodes being added.
        final storedUrls = await _getStoredEpisodeUrls(feedUrl);
        final episodes = await findEpisodes(feedUrl: feedUrl);

        final newEpisodes = episodes
            .where((e) => e.url != null && !storedUrls.contains(e.url))
            .toSet();
        final hasNewEpisodes = newEpisodes.isNotEmpty;

        if (hasNewEpisodes) {
          await _addPodcastUpdate(feedUrl, feedLastUpdated);
        }
      }

      updateProgress?.call((index + 1) / toCheckFeedUrls.length);
      await Future<void>.delayed(Duration.zero);
    }

    return podcastUpdates;
  }

  Future<bool> _hasPodcastEpisodesInDB(String feedUrl) async {
    final count =
        await (_db.selectOnly(_db.podcastEpisodeTable)
              ..addColumns([_db.podcastEpisodeTable.contentUrl])
              ..where(_db.podcastEpisodeTable.podcastFeedUrl.equals(feedUrl)))
            .get()
            .then((rows) => rows.length);
    return count > 0;
  }

  Future<List<Audio>> _loadEpisodesFromDb(String feedUrl) async {
    // Load episodes from DB WITHOUT loading the feed from the internet
    final rows = await (_db.select(
      _db.podcastEpisodeTable,
    )..where((t) => t.podcastFeedUrl.equals(feedUrl))).get();
    return rows
        .map(
          (r) => getEpisodeFromTableEntry(
            r,
            feedUrl: feedUrl,
            podcastTitle: getSubscribedPodcastName(feedUrl),
            podcastImage: getSubscribedPodcastImage(feedUrl),
          ),
        )
        .toSet()
        .toList();
  }

  Future<List<Audio>> findEpisodes({
    Item? item,
    String? feedUrl,
    bool loadFresh = false,
  }) async {
    if (item == null && item?.feedUrl == null && feedUrl == null) {
      printMessageInDebugMode('findEpisodes called without feedUrl or item');
      return Future.value([]);
    }

    printMessageInDebugMode(
      'Finding episodes for feedUrl: ${feedUrl ?? item!.feedUrl}, '
      'item: ${item != null ? item.trackName ?? item.collectionName : 'null'}',
    );

    final url = feedUrl ?? item!.feedUrl!;

    final hasEpisodesInDb =
        await _hasPodcastEpisodesInDB(url) && isPodcastSubscribed(url);

    if (!loadFresh && hasEpisodesInDb) {
      printMessageInDebugMode(
        'Skipping episode load from network for $url, loading from DB instead',
      );
      return _loadEpisodesFromDb(url);
    }

    final Podcast? podcast = await compute(loadPodcast, url);
    if (podcast?.image != null) {
      addSubscribedPodcastImage(feedUrl: url, imageUrl: podcast!.image!);
    }
    final episodes =
        podcast?.episodes
            .where((e) => e.contentUrl != null)
            .map(
              (e) => Audio.fromPodcast(
                episode: e,
                podcast: podcast,
                itemImageUrl: item?.artworkUrl600 ?? item?.artworkUrl,
                genre: item?.primaryGenreName,
              ),
            )
            .toList() ??
        <Audio>[];

    sortListByAudioFilter(
      audioFilter: AudioFilter.year,
      audios: episodes,
      descending: true,
    );

    // optimistically upsert episodes after finding them, so they are available faster when opening the podcast page
    await _upsertEpisodes(feedUrl: url, podcast: podcast, episodes: episodes);

    return episodes;
  }

  Future<void> _upsertEpisodes({
    required String feedUrl,
    required Podcast? podcast,
    required List<Audio> episodes,
  }) async {
    if (episodes.isEmpty) return;
    try {
      await _db.batch((batch) {
        for (final e in episodes) {
          if (e.url == null) continue;
          batch.insert(
            _db.podcastEpisodeTable,
            PodcastEpisodeTableCompanion.insert(
              podcastFeedUrl: feedUrl,
              title: e.title ?? '',
              episodeDescription: e.episodeDescription ?? '',
              podcastDescription: podcast?.description ?? '',
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
    } on Exception catch (e) {
      printMessageInDebugMode('Error upserting episodes: $e');
    }
  }

  Future<Set<String>> _getStoredEpisodeUrls(String feedUrl) async {
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

  // ── Downloads ──

  Future<String?> download({
    required Audio episode,
    required CancelToken cancelToken,
    required void Function(int received, int total) onProgress,
  }) async {
    final url = episode.url;
    if (url == null) {
      throw Exception('Invalid media, missing URL to download');
    }

    final downloadsDir = await _settingsService.downloadsDirOrDefault;
    if (downloadsDir == null) {
      throw Exception('Downloads directory not set');
    }

    if (!Directory(downloadsDir).existsSync()) {
      Directory(downloadsDir).createSync(recursive: true);
    }

    final path = p.join(downloadsDir, episode.podcastDownloadId);

    final response = await _dio.download(
      url,
      path,
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );

    if (response.statusCode == 200 && episode.feedUrl != null) {
      await addDownload(url: url, path: path, feedUrl: episode.feedUrl!);
      return path;
    }

    return null;
  }

  Map<String, String> _downloadedFilePaths = {};
  Map<String, String> get downloadedFilePaths => _downloadedFilePaths;
  String? getDownloadPath(Audio? audio) {
    final url = audio?.url;
    if (url == null) return null;
    final download = _downloadedFilePaths[url];
    return download != null && File(download).existsSync()
        ? _downloadedFilePaths[url]
        : null;
  }

  Set<String> feedsWithDownloads = {};

  Future<void> loadDownloadsFromDb() async {
    final rows = await _db.select(_db.downloadTable).get();
    _downloadedFilePaths = {for (final r in rows) r.url: r.filePath};
    feedsWithDownloads = rows.map((r) => r.feedUrl).toSet();
    await _cleanUpDownloadMismatches(rows);
  }

  Future<void> _cleanUpDownloadMismatches(List<DownloadTableData> rows) async {
    final nonExisting = <DownloadTableData>[];
    for (final entry in rows) {
      if (!File(entry.filePath).existsSync()) {
        printMessageInDebugMode(
          'Cleaning non-existing download:  [${entry.filePath} for URL: ${entry.url}]',
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
        _downloadedFilePaths.remove(entry.url);
      }

      final remainingRows = rows
          .where((r) => !urlsToDelete.contains(r.url))
          .toList();
      feedsWithDownloads = remainingRows.map((r) => r.feedUrl).toSet();
    }

    final downloadsDir = await _settingsService.downloadsDirOrDefault;
    final realDownloadFilePaths = downloadsDir != null
        ? Directory(
            downloadsDir,
          ).listSync().whereType<File>().map((f) => f.path).toSet()
        : <String>{};

    // delete files that do not have a corresponding entry in the database
    for (final filePath in realDownloadFilePaths) {
      if (!_downloadedFilePaths.containsValue(filePath)) {
        printMessageInDebugMode(
          'Deleting file without database entry: $filePath',
        );
        try {
          File(filePath).deleteSync();
        } on Exception catch (e) {
          printMessageInDebugMode('Error deleting file: $e');
        }
      }
    }
  }

  Future<void> addDownload({
    required String url,
    required String path,
    required String feedUrl,
  }) async {
    if (_downloadedFilePaths.containsKey(url)) return;
    _downloadedFilePaths[url] = path;
    feedsWithDownloads.add(feedUrl);
    await _db
        .into(_db.downloadTable)
        .insert(
          DownloadTableCompanion.insert(
            url: url,
            filePath: path,
            feedUrl: feedUrl,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> removeDownload({
    required String url,
    required String feedUrl,
  }) async {
    _deleteDownload(url);

    if (_downloadedFilePaths.containsKey(url)) {
      _downloadedFilePaths.remove(url);
      feedsWithDownloads.remove(feedUrl);
      await (_db.delete(
        _db.downloadTable,
      )..where((t) => t.url.equals(url))).go();
    }
  }

  void _deleteDownload(String url) {
    final path = _downloadedFilePaths[url];
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  Future<void> removeAllDownloads() async {
    for (var download in _downloadedFilePaths.entries) {
      _deleteDownload(download.key);
    }
    _downloadedFilePaths.clear();
    feedsWithDownloads.clear();
    await _db.delete(_db.downloadTable).go();
  }

  Future<void> removeFeedWithDownload(String feedUrl) async {
    if (!feedsWithDownloads.contains(feedUrl)) return;
    feedsWithDownloads.remove(feedUrl);
    await (_db.delete(
      _db.downloadTable,
    )..where((t) => t.feedUrl.equals(feedUrl))).go();
  }

  // ── Podcasts ──

  Set<String> _podcasts = {};
  List<String> get podcastFeedUrls => _podcasts.toList();
  Set<String> get podcasts => _podcasts;
  int get podcastsLength => _podcasts.length;

  Map<String, PodcastTableData> _podcastCache = {};

  Future<void> loadPodcastCacheFromDb() async {
    final rows = await (_db.select(
      _db.podcastTable,
    )..orderBy([(t) => OrderingTerm(expression: t.name)])).get();
    _podcastCache = {for (final r in rows) r.feedUrl: r};
    _podcasts = rows.map((r) => r.feedUrl).toSet();
  }

  String? getSubscribedPodcastImage(String feedUrl) =>
      _podcastCache[feedUrl]?.imageUrl;

  void addSubscribedPodcastImage({
    required String feedUrl,
    required String imageUrl,
  }) {
    (_db.update(_db.podcastTable)..where((t) => t.feedUrl.equals(feedUrl)))
        .write(PodcastTableCompanion(imageUrl: Value(imageUrl)))
        .then((_) {
          final cached = _podcastCache[feedUrl];
          if (cached != null) {
            _podcastCache[feedUrl] = cached.copyWith(imageUrl: Value(imageUrl));
          }
        });
  }

  String? getSubscribedPodcastName(String feedUrl) =>
      _podcastCache[feedUrl]?.name;

  String? getSubscribedPodcastArtist(String feedUrl) =>
      _podcastCache[feedUrl]?.artist;

  Future<void> addPodcast({
    required String feedUrl,
    required String? imageUrl,
    required String name,
    required String artist,
  }) async {
    if (podcastFeedUrls.contains(feedUrl)) return;
    _podcasts.add(feedUrl);
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
    podcasts,
  ) async {
    if (podcasts.isEmpty) return;
    final newPodcasts = podcasts
        .where((p) => !_podcasts.contains(p.feedUrl))
        .toList();
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
      _podcasts.add(p.feedUrl);
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

  Set<String> get ascendingPodcasts =>
      _podcasts.where((p) => _podcastCache[p]?.ascending == true).toSet();

  Set<String> podcastUpdates = {};

  Future<void> loadPodcastUpdatesFromDb() async {
    final rows = await _db.select(_db.podcastUpdateTable).get();
    podcastUpdates = rows.map((r) => r.podcastFeedUrl).toSet();
  }

  Future<void> _addPodcastLastUpdated({
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

  bool podcastUpdateAvailable(String feedUrl) =>
      podcastUpdates.contains(feedUrl) == true;

  Future<void> _addPodcastUpdate(String feedUrl, DateTime lastUpdated) async {
    if (podcastUpdates.contains(feedUrl) == true) return;
    podcastUpdates.add(feedUrl);
    await _db
        .into(_db.podcastUpdateTable)
        .insert(
          PodcastUpdateTableCompanion.insert(podcastFeedUrl: feedUrl),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> removePodcastUpdates({
    Iterable<String>? feedUrls,
    required void Function(double) updateProgress,
  }) async {
    if (podcastUpdates.isEmpty) {
      await loadPodcastUpdatesFromDb();
    }
    final urls = feedUrls ?? podcastFeedUrls;
    for (final (index, url) in urls.indexed) {
      await removePodcastUpdate(url);
      updateProgress((index + 1) / urls.length);
    }
  }

  Future<void> removePodcastUpdate(String feedUrl) async {
    if (podcastUpdates.isEmpty) return;
    podcastUpdates.remove(feedUrl);
    await (_db.delete(
      _db.podcastUpdateTable,
    )..where((t) => t.podcastFeedUrl.equals(feedUrl))).go();
  }

  Future<void> removePodcast(String feedUrl) async {
    if (!podcastFeedUrls.contains(feedUrl)) return;
    printMessageInDebugMode('Cleaning up unsubscribed podcast: $feedUrl');

    await removeFeedWithDownload(feedUrl);
    await removePodcastUpdate(feedUrl);
    await removeFeedWithDownload(feedUrl);
    await (_db.delete(
      _db.podcastEpisodeTable,
    )..where((t) => t.podcastFeedUrl.equals(feedUrl))).go();

    await (_db.delete(
      _db.podcastUpdateTable,
    )..where((t) => t.podcastFeedUrl.equals(feedUrl))).go();
    await (_db.delete(
      _db.podcastTable,
    )..where((t) => t.feedUrl.equals(feedUrl))).go();

    await (_db.delete(
      _db.downloadTable,
    )..where((t) => t.feedUrl.equals(feedUrl))).go();

    _podcasts.remove(feedUrl);
    _podcastCache.remove(feedUrl);

    await _db.reclaimDiskSpace();
  }

  Future<void> removeAllPodcasts() async {
    _podcasts.clear();
    podcastUpdates.clear();
    _podcastCache.clear();
    await Future.wait([
      _db.delete(_db.podcastUpdateTable).go(),
      _db.delete(_db.podcastTable).go(),
    ]);
  }

  Future<void> wipeAndBuildPodcastLibrary() async {
    await removeAllDownloads();
    await removeAllPodcasts();
    await loadPodcastCacheFromDb();
    await loadPodcastUpdatesFromDb();
    await loadDownloadsFromDb();
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

  bool isPodcastSubscribed(String pageId) => _podcasts.contains(pageId);

  Audio getEpisodeFromTableEntry(
    PodcastEpisodeTableData data, {
    required String feedUrl,
    String? podcastTitle,
    String? podcastImage,
  }) {
    return Audio(
      url: data.contentUrl,
      title: data.title,
      episodeDescription: data.episodeDescription,
      podcastDescription: data.podcastDescription,
      publicationDate: data.publicationDate.millisecondsSinceEpoch,
      durationMs: data.durationMs?.toDouble(),
      imageUrl: data.imageUrl,
      albumArtUrl: podcastImage,
      podcastTitle: data.title,
      feedUrl: feedUrl,
    );
  }
}

Future<Podcast?> loadPodcast(String url) => Feed.loadFeed(url: url);

class PodcastUpdate {
  final String feedUrl;
  final List<Audio> episodes;

  const PodcastUpdate({required this.feedUrl, required this.episodes});
}

class FindEpisodesTimeoutException implements Exception {
  final String? message;

  FindEpisodesTimeoutException({this.message});

  @override
  String toString() =>
      message ?? 'Timeout while fetching episodes for the podcast';
}
