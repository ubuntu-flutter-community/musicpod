import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:podcast_search/podcast_search.dart' hide Value;
import 'package:synchronized/synchronized.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import '../common/persistence/database.dart';
import '../common/view/audio_filter.dart';
import '../common/view/languages.dart';
import '../extensions/date_time_x.dart';
import '../extensions/string_x.dart';
import '../notifications/notifications_service.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
import 'data/podcast_genre.dart';

@singleton
class PodcastService {
  final NotificationsService _notificationsService;
  final SettingsService _settingsService;
  final Database _db;
  PodcastService({
    required NotificationsService notificationsService,
    required SettingsService settingsService,
    required Database database,
  }) : _notificationsService = notificationsService,
       _settingsService = settingsService,
       _db = database {
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

  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;

  void _notify() {
    if (_propertiesChangedController.hasListener) {
      _propertiesChangedController.add(true);
    }
  }

  @PostConstruct(preResolve: true)
  Future<void> initService() async {
    await _loadPodcastCache();
    await _loadPodcastUpdates();
    await _loadDownloads();
    _notify();
  }

  @disposeMethod
  Future<void> dispose() => _propertiesChangedController.close();

  SearchResult? _searchResult;
  Search? _search;

  void initSearchProvider({bool forceInit = false}) {
    if (_search == null || forceInit) {
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
  }

  List<PodcastGenre> get cachedPodcastGenres => _podcastGenreCache;
  List<PodcastGenre> _podcastGenreCache = [];
  Future<List<PodcastGenre>> loadGenres({bool force = false}) async {
    if (_podcastGenreCache.isNotEmpty && !force) {
      return _podcastGenreCache;
    }

    var genres = <String>{};
    try {
      genres = await _search?.genres().toSet() ?? <String>{};
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
        result = await _search?.charts(
          genre: podcastGenre == PodcastGenre.all ? '' : podcastGenre.id,
          limit: limit,
          country: country ?? Country.none,
          language: country != null || language?.isoCode == null
              ? ''
              : language!.isoCode,
        );
      } else {
        result = await _search?.search(
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
      return _searchResult;
    }
    printMessageInDebugMode(
      'Podcast search result: successful=${result?.successful}, '
      'itemCount=${result?.items.length}, '
      'query=$searchQuery',
    );

    if (result != null &&
        result.successful &&
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
  Future<List<String>> checkForUpdates({
    Set<String>? feedUrls,
    required String Function(int length) multiUpdateMessage,
    void Function(double progress)? updateProgress,
  }) => _syncLock.synchronized(
    () => _checkForUpdates(
      feedUrls: feedUrls,
      multiUpdateMessage: multiUpdateMessage,
      updateProgress: updateProgress,
    ),
  );

  Future<List<String>> _checkForUpdates({
    Set<String>? feedUrls,
    required String Function(int length) multiUpdateMessage,
    void Function(double progress)? updateProgress,
  }) async {
    final newUpdateFeedUrls = <String>{};

    for (final feedUrl in (feedUrls ?? _podcasts)) {
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
        await addPodcastLastUpdated(
          feedUrl: feedUrl,
          lastUpdated: feedLastUpdated,
        );

        // Compare actual episode URLs to detect genuinely new episodes,
        // since Last-Modified can change without new episodes being added.
        final storedUrls = await _getStoredEpisodeUrls(feedUrl);
        final episodes = await findEpisodes(feedUrl: feedUrl);
        final hasNewEpisodes = episodes.any(
          (e) => e.url != null && !storedUrls.contains(e.url),
        );

        if (hasNewEpisodes) {
          await addPodcastUpdate(feedUrl, feedLastUpdated);
          newUpdateFeedUrls.add(feedUrl);
        }
      }

      updateProgress?.call(
        newUpdateFeedUrls.length / (feedUrls?.length ?? _podcasts.length),
      );
      await Future<void>.delayed(Duration.zero);
    }

    if (newUpdateFeedUrls.isNotEmpty) {
      final msg = multiUpdateMessage(newUpdateFeedUrls.length);
      _notificationsService.notify(message: msg);
    }
    return newUpdateFeedUrls.toList();
  }

  Future<List<Audio>> findEpisodes({Item? item, String? feedUrl}) async {
    if (item == null && item?.feedUrl == null && feedUrl == null) {
      printMessageInDebugMode('findEpisodes called without feedUrl or item');
      return Future.value([]);
    }

    final url = feedUrl ?? item!.feedUrl!;

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

  Map<String, String> _downloads = {};
  Map<String, String> get downloads => _downloads;
  String? getDownload(String? url) => _downloads[url];

  Set<String> _feedsWithDownloads = {};
  bool feedHasDownloads(String feedUrl) =>
      _feedsWithDownloads.contains(feedUrl);
  int get feedsWithDownloadsLength => _feedsWithDownloads.length;

  Future<void> _loadDownloads() async {
    final rows = await _db.select(_db.downloadTable).get();
    _downloads = {for (final r in rows) r.url: r.filePath};
    _feedsWithDownloads = rows.map((r) => r.feedUrl).toSet();
  }

  Future<void> addDownload({
    required String url,
    required String path,
    required String feedUrl,
  }) async {
    if (_downloads.containsKey(url)) return;
    _downloads[url] = path;
    _feedsWithDownloads.add(feedUrl);
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
    _notify();
  }

  Future<void> removeDownload({
    required String url,
    required String feedUrl,
  }) async {
    _deleteDownload(url);

    if (_downloads.containsKey(url)) {
      _downloads.remove(url);
      _feedsWithDownloads.remove(feedUrl);
      await (_db.delete(
        _db.downloadTable,
      )..where((t) => t.url.equals(url))).go();
      _notify();
    }
  }

  void _deleteDownload(String url) {
    final path = _downloads[url];
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  Future<void> removeAllDownloads() async {
    for (var download in _downloads.entries) {
      _deleteDownload(download.key);
    }
    _downloads.clear();
    _feedsWithDownloads.clear();
    await _db.delete(_db.downloadTable).go();
    _notify();
  }

  void _removeFeedWithDownload(String feedUrl) {
    if (!_feedsWithDownloads.contains(feedUrl)) return;
    _feedsWithDownloads.remove(feedUrl);
    (_db.delete(
      _db.downloadTable,
    )..where((t) => t.feedUrl.equals(feedUrl))).go().then((_) => _notify());
  }

  // ── Podcasts ──

  Set<String> _podcasts = {};
  bool isPodcastSubscribed(String feedUrl) => _podcasts.contains(feedUrl);
  List<String> get podcastFeedUrls => _podcasts.toList();
  Set<String> get podcasts => _podcasts;
  int get podcastsLength => _podcasts.length;

  Map<String, PodcastTableData> _podcastCache = {};

  Future<void> _loadPodcastCache() async {
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
          _notify();
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
    if (isPodcastSubscribed(feedUrl)) return;
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
    _notify();
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
    _notify();
  }

  bool showPodcastAscending(String feedUrl) =>
      _podcastCache[feedUrl]?.ascending ?? false;

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
    _notify();
  }

  Set<String>? _podcastUpdates;
  int? get podcastUpdatesLength => _podcastUpdates?.length;

  Future<void> _loadPodcastUpdates() async {
    final rows = await _db.select(_db.podcastUpdateTable).get();
    _podcastUpdates = rows.map((r) => r.podcastFeedUrl).toSet();
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
    _notify();
  }

  String? getPodcastLastUpdated(String feedUrl) =>
      _podcastCache[feedUrl]?.lastUpdated.toPodcastTimeStamp;

  bool podcastUpdateAvailable(String feedUrl) =>
      _podcastUpdates?.contains(feedUrl) == true;

  Future<void> addPodcastUpdate(String feedUrl, DateTime lastUpdated) async {
    if (_podcastUpdates?.contains(feedUrl) == true) return;
    _podcastUpdates?.add(feedUrl);
    await _db
        .into(_db.podcastUpdateTable)
        .insert(
          PodcastUpdateTableCompanion.insert(podcastFeedUrl: feedUrl),
          mode: InsertMode.insertOrIgnore,
        );
    _notify();
  }

  Future<void> removePodcastUpdate(String feedUrl) async {
    if (_podcastUpdates?.isNotEmpty == false) return;
    _podcastUpdates?.remove(feedUrl);
    await (_db.delete(
      _db.podcastUpdateTable,
    )..where((t) => t.podcastFeedUrl.equals(feedUrl))).go();
    _notify();
  }

  void removePodcast(String feedUrl) {
    if (!isPodcastSubscribed(feedUrl)) return;
    _podcasts.remove(feedUrl);
    _podcastCache.remove(feedUrl);
    _removeFeedWithDownload(feedUrl);
    (_db.delete(
      _db.podcastUpdateTable,
    )..where((t) => t.podcastFeedUrl.equals(feedUrl))).go();
    (_db.delete(
      _db.podcastTable,
    )..where((t) => t.feedUrl.equals(feedUrl))).go().then((_) => _notify());
  }

  Future<void> removeAllPodcasts() async {
    _podcasts.clear();
    _podcastUpdates?.clear();
    _podcastCache.clear();
    await Future.wait([
      _db.delete(_db.podcastUpdateTable).go(),
      _db.delete(_db.podcastTable).go(),
    ]);
    _notify();
  }

  Future<void> wipeAndBuildPodcastLibrary() async {
    await removeAllDownloads();
    await removeAllPodcasts();
    await initService();
  }
}

Future<Podcast?> loadPodcast(String url) async {
  try {
    return await Feed.loadFeed(url: url);
  } catch (e) {
    printMessageInDebugMode(e);
    return null;
  }
}
