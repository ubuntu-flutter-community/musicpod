import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:podcast_search/podcast_search.dart' hide Value;
import 'package:synchronized/synchronized.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import '../common/view/audio_filter.dart';
import '../common/view/languages.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
import 'data/podcast_genre.dart';
import 'persistence/podcast_dao.dart';

@lazySingleton
class PodcastService {
  final SettingsService _settingsService;
  final PodcastDao _dao;

  PodcastService({
    required SettingsService settingsService,
    required PodcastDao dao,
  }) : _settingsService = settingsService,
       _dao = dao {
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

  static const podcastMaxLimit = 80;
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
          limit: limit > podcastMaxLimit ? podcastMaxLimit : limit,
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
          limit: limit > podcastMaxLimit ? podcastMaxLimit : limit,
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
      throw throw PodcastSearchNotSuccessfulException();
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
    await loadPodcastUpdates();

    for (final (index, feedUrl) in toCheckFeedUrls.indexed) {
      final storedTimeStamp = getPodcastLastUpdated(feedUrl);
      final name = getSubscribedPodcastName(feedUrl);

      printMessageInDebugMode('checking update for: ${name ?? feedUrl} ');
      printMessageInDebugMode(
        'storedTimeStamp: ${storedTimeStamp ?? 'no timestamp stored'}',
      );

      await _addPodcastLastUpdated(
        feedUrl: feedUrl,
        lastUpdated: DateTime.now(),
      );

      // Compare actual episode URLs to detect genuinely new episodes,
      // since Last-Modified can change without new episodes being added.
      final storedUrls = await _dao.getStoredEpisodeUrls(feedUrl);
      final allFreshEpisodes = await findEpisodes(
        feedUrl: feedUrl,
        tryFromDbOnly: false,
      );

      final newEpisodes = allFreshEpisodes
          .where((e) => e.url != null && !storedUrls.contains(e.url))
          .toSet();

      if (newEpisodes.isNotEmpty) {
        await _addPodcastUpdate(feedUrl);
      }

      updateProgress?.call((index + 1) / toCheckFeedUrls.length);
      await Future<void>.delayed(Duration.zero);
    }

    return podcastUpdates;
  }

  Future<List<Audio>> findEpisodes({
    Item? item,
    String? feedUrl,
    required bool tryFromDbOnly,
  }) async {
    if (item == null && item?.feedUrl == null && feedUrl == null) {
      throw Exception('findEpisodes called without feedUrl or item');
    }

    final url = feedUrl ?? item!.feedUrl!;

    final hasEpisodesInDb =
        await _dao.hasPodcastStoredEpisodes(url) && isPodcastSubscribed(url);

    if (tryFromDbOnly && hasEpisodesInDb) {
      printMessageInDebugMode(
        'Skipping episode load from network for $url, loading from DB instead',
      );
      return _dao.getEpisodes(url);
    }

    printMessageInDebugMode(
      'Fetching all episodes from ${_search.searchProvider is ITunesProvider ? 'iTunes' : 'podcastindex'} for feedUrl: ${feedUrl ?? item!.feedUrl}, '
      'item: ${item != null ? item.trackName ?? item.collectionName : 'null'}',
    );
    final Podcast? podcast = await compute(loadPodcast, url);
    if (podcast?.image != null) {
      addSubscribedPodcastImage(
        feedUrl: url,
        imageUrl: podcast!.image!,
        title: podcast.title ?? '',
      );
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
    await _dao.upsertEpisodes(
      feedUrl: url,
      podcastDescription: podcast?.description,
      episodes: episodes,
    );

    return episodes;
  }

  // ── Downloads ──

  Map<String, String> _downloadUrlsToFilePaths = {};
  String? getDownloadPath(Audio? audio) {
    final url = audio?.url;
    if (url == null) return null;
    final download = _downloadUrlsToFilePaths[url];
    return download != null && File(download).existsSync()
        ? _downloadUrlsToFilePaths[url]
        : null;
  }

  Set<String> feedsWithDownloads = {};

  Future<void> loadDownloads() async {
    final res = await _dao.getDownloads();
    _downloadUrlsToFilePaths = res.downloadFilePaths;
    feedsWithDownloads = res.feedsWithDownloads;
    await _cleanUpDownloadMismatches();
  }

  Future<void> _cleanUpDownloadMismatches() async {
    final res = await _dao.cleanUpDownloadMismatches(
      downloadFilePaths: _downloadUrlsToFilePaths,
      feedsWithDownloads: feedsWithDownloads,
      downloadsDir: await _settingsService.downloadsDirOrDefault,
    );

    _downloadUrlsToFilePaths = res.newDownloadFilePaths;
    feedsWithDownloads = res.newFeedsWithDownloads;
  }

  Future<void> addDownload({
    required String url,
    required String path,
    required String feedUrl,
  }) async {
    if (_downloadUrlsToFilePaths.containsKey(url)) return;
    await _dao.addDownload(url: url, path: path, feedUrl: feedUrl);
    _downloadUrlsToFilePaths[url] = path;
    feedsWithDownloads.add(feedUrl);
  }

  Future<void> removeDownload({
    required String url,
    required String feedUrl,
  }) async {
    await _deleteDownloadInFileSystem(url);

    if (_downloadUrlsToFilePaths.containsKey(url)) {
      await _dao.deleteDownload([url]);
      _downloadUrlsToFilePaths.remove(url);
      feedsWithDownloads.remove(feedUrl);
    }
  }

  Future<void> _deleteDownloadInFileSystem(String url) async {
    final path = _downloadUrlsToFilePaths[url];
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> removeAllDownloads() async {
    final successFullDeletes = <String>{};
    for (var download in _downloadUrlsToFilePaths.entries) {
      try {
        await _deleteDownloadInFileSystem(download.key);
        successFullDeletes.add(download.key);
      } on Exception catch (e, st) {
        printMessageInDebugMode(
          'Error deleting download file for url ${download.key}: $e\n$st',
        );
      }
    }

    await _dao.deleteDownload(successFullDeletes.toList());

    await loadDownloads();
  }

  Set<String> _podcasts = {};
  bool isPodcastSubscribed(String pageId) => _podcasts.contains(pageId);

  List<String> get podcastFeedUrls => _podcasts.toList();
  Set<String> get podcasts => _podcasts;
  int get podcastsLength => _podcasts.length;

  Future<void> loadPodcasts() async {
    _podcasts = await _dao.getPodcasts();
  }

  String? getSubscribedPodcastImage(String feedUrl) =>
      _dao.getSubscribedPodcastImage(feedUrl);

  void addSubscribedPodcastImage({
    required String feedUrl,
    required String imageUrl,
    required String title,
  }) => _dao.updateSubscribedPodcastImage(
    feedUrl: feedUrl,
    imageUrl: imageUrl,
    title: title,
  );

  String? getSubscribedPodcastName(String feedUrl) =>
      _dao.getSubscribedPodcastName(feedUrl);

  String? getSubscribedPodcastArtist(String feedUrl) =>
      _dao.getSubscribedPodcastArtist(feedUrl);

  Future<void> addPodcast({
    required String feedUrl,
    required String? imageUrl,
    required String name,
    required String artist,
  }) async {
    if (podcastFeedUrls.contains(feedUrl)) return;
    await _dao.addPodcast(
      feedUrl: feedUrl,
      imageUrl: imageUrl,
      name: name,
      artist: artist,
    );

    _podcasts.add(feedUrl);
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

    await _dao.addPodcasts(newPodcasts);

    for (final p in newPodcasts) {
      _podcasts.add(p.feedUrl);
    }
  }

  Future<void> reorderPodcast({
    required String feedUrl,
    required bool ascending,
  }) => _dao.reorderPodcast(feedUrl: feedUrl, ascending: ascending);

  Set<String> get ascendingPodcasts => _dao.ascendingPodcasts;

  Set<String> podcastUpdates = {};

  Future<void> loadPodcastUpdates() async {
    podcastUpdates = await _dao.getPodcastUpdates();
  }

  Future<void> _addPodcastLastUpdated({
    required String feedUrl,
    required DateTime lastUpdated,
  }) => _dao.addPodcastLastUpdated(feedUrl: feedUrl, lastUpdated: lastUpdated);

  String? getPodcastLastUpdated(String feedUrl) =>
      _dao.getPodcastLastUpdated(feedUrl);

  bool podcastUpdateAvailable(String feedUrl) =>
      podcastUpdates.contains(feedUrl);

  Future<void> _addPodcastUpdate(String feedUrl) async {
    if (podcastUpdates.contains(feedUrl)) return;
    await _dao.addPodcastUpdate(feedUrl);
    podcastUpdates.add(feedUrl);
  }

  Future<void> removePodcastUpdates({
    Iterable<String>? feedUrls,
    required void Function(double) updateProgress,
  }) async {
    if (podcastUpdates.isEmpty) {
      await loadPodcastUpdates();
    }
    final urls = feedUrls ?? podcastFeedUrls;
    for (final (index, url) in urls.indexed) {
      await removePodcastUpdate(url);
      updateProgress((index + 1) / urls.length);
    }
  }

  Future<void> removePodcastUpdate(String feedUrl) async {
    if (podcastUpdates.isEmpty) return;
    await _dao.deletePodcastUpdate(feedUrl);
    podcastUpdates.remove(feedUrl);
  }

  Future<void> removePodcast(String feedUrl) async {
    if (!podcastFeedUrls.contains(feedUrl)) return;
    printMessageInDebugMode('Cleaning up unsubscribed podcast: $feedUrl');
    await _dao.deletePodcast(feedUrl);
    _podcasts.remove(feedUrl);
  }

  Future<void> updateAudioDuration(Audio audio) =>
      _dao.updateAudioDuration(audio);

  Future<void> wipeAndBuildPodcastLibrary() async {
    await _dao.deleteAllPodcasts();
    await loadPodcasts();
    await loadPodcastUpdates();
    await loadDownloads();
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

  static const Duration timeoutDuration = Duration(seconds: 30);

  FindEpisodesTimeoutException({this.message});

  @override
  String toString() =>
      message ?? 'Timeout while fetching episodes for the podcast';
}

class PodcastSearchNotSuccessfulException implements Exception {
  @override
  String toString() =>
      'This podcast search was not successfull, are you connected to the internet? If yes this might be a server issue.';
}
