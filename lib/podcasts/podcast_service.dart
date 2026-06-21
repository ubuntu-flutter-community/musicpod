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
import 'data/podcast_short_info.dart';
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

  Future<List<PodcastGenre>> loadGenres({bool force = false}) async {
    var genres = <String>{};
    try {
      genres = await _search.genres().toSet();
    } on Exception catch (e, s) {
      printErrorInDebugMode(e, trace: s, tag: '$PodcastService');
    }

    return genres.map((g) => PodcastGenre.fromString(g)).toSet().toList();
  }

  static const podcastMaxLimit = 80;
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
    } on Exception catch (e, s) {
      printErrorInDebugMode(e, trace: s, tag: '$PodcastService');
      rethrow;
    }

    printInfoInDebugMode(
      'Podcast search result: successful=${result.successful}, '
      'itemCount=${result.items.length}, '
      'query=$searchQuery',
      tag: '$PodcastService',
    );

    if (!result.successful) {
      throw PodcastSearchNotSuccessfulException();
    }

    return result;
  }

  final _syncLock = Lock();
  Future<Set<String>> checkForUpdates({
    required Iterable<String> feedUrls,
    void Function(double progress)? updateProgress,
  }) => _syncLock.synchronized(
    () async => _checkForUpdates(
      toCheckFeedUrls: feedUrls.isEmpty
          ? (await getSubscribedPodcasts())
          : feedUrls,
      updateProgress: updateProgress,
    ),
  );

  Future<Set<String>> _checkForUpdates({
    required Iterable<String> toCheckFeedUrls,
    void Function(double progress)? updateProgress,
  }) async {
    await getPodcastUpdates();

    for (final (index, feedUrl) in toCheckFeedUrls.indexed) {
      final storedTimeStamp = await getPodcastLastUpdated(feedUrl);
      final name = await getPodcastName(feedUrl);

      printInfoInDebugMode(
        'checking update for: $name',
        tag: '$PodcastService',
      );
      printInfoInDebugMode(
        'storedTimeStamp: $storedTimeStamp',
        tag: '$PodcastService',
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
        genre: null,
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

    return getPodcastUpdates();
  }

  Future<List<Audio>> findEpisodes({
    required String feedUrl,
    required bool tryFromDbOnly,
    required String? genre,
  }) async {
    final hasEpisodesInDb = await _dao.hasPodcastStoredEpisodes(feedUrl);

    if (tryFromDbOnly && hasEpisodesInDb) {
      printInfoInDebugMode(
        'Skipping episode load from network for $feedUrl, loading from DB instead',
        tag: '$PodcastService',
      );
      return _dao.getEpisodes(feedUrl);
    }

    printInfoInDebugMode(
      'Fetching all episodes from ${_search.searchProvider is ITunesProvider ? 'iTunes' : 'podcastindex'} for feedUrl: $feedUrl',
      tag: '$PodcastService',
    );
    final podcast = await compute(loadPodcast, feedUrl);

    // Optimistically add the podcast to the DB unsubscribed
    await _dao.addPodcast(
      feedUrl: feedUrl,
      subscribe: false,
      imageUrl: podcast.image,
      name: podcast.title ?? '',
      artist: podcast.copyright ?? '',
    );

    if (genre != null) {
      await addPodcastGenre(feedUrl: feedUrl, genreName: genre);
    }

    final episodes = podcast.episodes
        .where((e) => e.contentUrl != null)
        .map((e) => Audio.fromPodcast(episode: e, podcast: podcast))
        .toList();

    sortListByAudioFilter(
      audioFilter: AudioFilter.year,
      audios: episodes,
      descending: true,
    );

    // optimistically upsert episodes after finding them, so they are available faster when opening the podcast page
    await _dao.upsertEpisodes(
      feedUrl: feedUrl,
      podcastDescription: podcast.description,
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
    _deleteDownloadInFileSystem(url);

    if (_downloadUrlsToFilePaths.containsKey(url)) {
      await _dao.deleteDownload([url]);
      _downloadUrlsToFilePaths.remove(url);
      feedsWithDownloads.remove(feedUrl);
    }
  }

  void _deleteDownloadInFileSystem(String url) async {
    final path = _downloadUrlsToFilePaths[url];
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  Future<void> removeAllDownloads() async {
    final successFullDeletes = <String>{};
    for (var download in _downloadUrlsToFilePaths.entries) {
      try {
        _deleteDownloadInFileSystem(download.key);
        successFullDeletes.add(download.key);
      } on Exception catch (e, st) {
        printErrorInDebugMode(e, trace: st, tag: '$PodcastService');
        rethrow;
      }
    }

    await _dao.deleteDownload(successFullDeletes.toList());

    await loadDownloads();
  }

  Future<bool> isPodcastSubscribed(String pageId) =>
      _dao.isPodcastSubscribed(pageId);

  Future<Set<String>> getSubscribedPodcasts() => _dao.getSubscribedPodcasts();

  Future<PodcastShortInfo?> getPodcastShortInfo(String feedUrl) =>
      _dao.getPodcastShortInfo(feedUrl);

  Future<String?> getPodcastName(String feedUrl) =>
      _dao.getPodcastName(feedUrl);

  Future<String?> getSubscribedPodcastArtist(String feedUrl) =>
      _dao.getPodcastArtist(feedUrl);

  Future<void> togglePodcastSubscription({required String feedUrl}) =>
      _dao.togglePodcastSubscription(feedUrl: feedUrl);

  Future<void> addPodcasts(
    List<({String feedUrl, String? imageUrl, String name, String artist})>
    podcasts,
  ) async {
    if (podcasts.isEmpty) return;
    final newPodcasts = podcasts.toList();
    if (newPodcasts.isEmpty) return;

    await _dao.addPodcasts(newPodcasts);
  }

  Future<void> reorderPodcast({
    required String feedUrl,
    required bool ascending,
  }) => _dao.reorderPodcast(feedUrl: feedUrl, ascending: ascending);

  Future<Set<String>> get ascendingPodcasts => _dao.ascendingPodcasts;

  Future<Set<String>> getPodcastUpdates() => _dao.getPodcastUpdates();

  Future<void> _addPodcastLastUpdated({
    required String feedUrl,
    required DateTime lastUpdated,
  }) => _dao.addPodcastLastUpdated(feedUrl: feedUrl, lastUpdated: lastUpdated);

  Future<String?> getPodcastLastUpdated(String feedUrl) =>
      _dao.getPodcastLastUpdated(feedUrl);

  Future<void> _addPodcastUpdate(String feedUrl) =>
      _dao.addPodcastUpdate(feedUrl);

  Future<void> removePodcastUpdates({
    Iterable<String>? feedUrls,
    required void Function(double) updateProgress,
  }) async {
    final urls = feedUrls ?? (await getSubscribedPodcasts());
    for (final (index, url) in urls.indexed) {
      await removePodcastUpdate(url);
      updateProgress((index + 1) / urls.length);
    }
  }

  Future<void> removePodcastUpdate(String feedUrl) =>
      _dao.deletePodcastUpdate(feedUrl);

  Future<Set<String>> deleteOrphanPodcastData() => _dao.deleteOrphanEpisodes();

  Future<Set<String>> deletePodcastAndFriends({
    required Set<String> deleteMeUrls,
  }) => _dao.deletePodcastAndFriends(deleteMeUrls: deleteMeUrls);

  Future<void> updateAudioDuration(Audio audio) =>
      _dao.updateAudioDuration(audio);

  Future<void> wipeAndBuildPodcastLibrary() async {
    await _dao.deleteAllPodcasts();
    await getPodcastUpdates();
    await loadDownloads();
  }

  Future<String?> findPodcastGenre(String feedUrl) =>
      _dao.getPodcastGenre(feedUrl);

  Future<void> addPodcastGenre({
    required String feedUrl,
    required String genreName,
  }) => _dao.insertPodcastGenre(feedUrl: feedUrl, genreName: genreName);
}

Future<Podcast> loadPodcast(String url) => Feed.loadFeed(url: url);

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
