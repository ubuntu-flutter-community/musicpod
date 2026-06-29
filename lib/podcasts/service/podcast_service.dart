import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:podcast_search/podcast_search.dart' hide Value;
import 'package:synchronized/synchronized.dart';

import '../../common/data/audio.dart';
import '../../common/logging.dart';
import '../../common/view/audio_filter.dart';
import '../../common/view/languages.dart';
import '../../settings/service/settings_service.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../data/podcast_exceptions.dart';
import '../data/podcast_genre.dart';
import '../data/podcast_short_info.dart';
import '../persistence/podcast_dao.dart';

@lazySingleton
class PodcastService {
  final SettingsService _settingsService;
  final PodcastDao _dao;

  PodcastService({
    required SettingsService settingsService,
    required PodcastDao dao,
  }) : _settingsService = settingsService,
       _dao = dao {
    Logger.o(tag: '$PodcastService');
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

  void initSearchProvider(SearchProvider searchProvider) =>
      _search = Search(searchProvider: searchProvider);

  Future<List<PodcastGenre>> loadGenres({bool force = false}) async {
    var genres = <String>{};
    try {
      genres = await _search.genres().toSet();
    } on Exception catch (e, s) {
      Logger.e(e, trace: s, tag: '$PodcastService');
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
      Logger.e(e, trace: s, tag: '$PodcastService');
      rethrow;
    }

    Logger.i(
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
  Future<Map<String, Set<Audio>>> checkForUpdates({
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

  Future<Map<String, Set<Audio>>> _checkForUpdates({
    required Iterable<String> toCheckFeedUrls,
    void Function(double progress)? updateProgress,
  }) async {
    final Map<String, Set<Audio>> newEpisodeMap = {};

    for (final (index, feedUrl) in toCheckFeedUrls.indexed) {
      final storedTimeStamp = await getPodcastLastUpdated(feedUrl);
      final name = await getPodcastName(feedUrl);

      Logger.i('checking update for: $name', tag: '$PodcastService');
      Logger.i('storedTimeStamp: $storedTimeStamp', tag: '$PodcastService');

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
        newEpisodeMap[feedUrl] = newEpisodes;
        await _addPodcastUpdate(feedUrl);
      }

      updateProgress?.call((index + 1) / toCheckFeedUrls.length);
      await Future<void>.delayed(Duration.zero);
    }

    return newEpisodeMap;
  }

  Future<List<Audio>> findEpisodes({
    required String feedUrl,
    required bool tryFromDbOnly,
    AudioSortOrder? order,
  }) async {
    final theOrder = order ?? await _dao.getPodcastOrder(feedUrl);
    final subscribe = await isPodcastSubscribed(feedUrl);
    final hasEpisodesInDb = await _dao.hasPodcastStoredEpisodes(feedUrl);

    if (tryFromDbOnly &&
        hasEpisodesInDb &&
        await _dao.getPodcastImage(feedUrl) != null) {
      Logger.i(
        'Skipping episode load from network for $feedUrl, loading from DB instead',
        tag: '$PodcastService',
      );
      final episodes = await _dao.getEpisodes(feedUrl);
      sortListByAudioFilter(
        audioFilter: AudioFilter.year,
        audios: episodes,
        order: theOrder,
      );
      await reorderPodcast(feedUrl: feedUrl, order: theOrder);
      return episodes;
    }

    Logger.i(
      'Fetching all episodes from ${_search.searchProvider is ITunesProvider ? 'iTunes' : 'podcastindex'} for feedUrl: $feedUrl',
      tag: '$PodcastService',
    );
    final podcast = await compute(loadPodcast, feedUrl).timeout(
      FindEpisodesTimeoutException.timeoutDuration,
      onTimeout: () => throw FindEpisodesTimeoutException(),
    );

    // Optimistically add the podcast to the DB with the current subscription status
    await _dao.addPodcast(
      feedUrl: feedUrl,
      subscribe: subscribe,
      imageUrl: podcast.image,
      name: podcast.title ?? '',
      artist: podcast.copyright ?? '',
    );

    final episodes = podcast.episodes
        .where((e) => e.contentUrl != null)
        .map((e) => Audio.fromPodcast(episode: e, podcast: podcast))
        .toList();

    sortListByAudioFilter(
      audioFilter: AudioFilter.year,
      audios: episodes,
      order: theOrder,
    );

    await reorderPodcast(feedUrl: feedUrl, order: theOrder);

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
        Logger.e(e, trace: st, tag: '$PodcastService');
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
    required AudioSortOrder order,
  }) => _dao.reorderPodcast(feedUrl: feedUrl, order: order);

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
    required Iterable<String> feedUrls,
    required void Function(double) updateProgress,
  }) async {
    for (final (index, url) in feedUrls.indexed) {
      await _dao.deletePodcastUpdate(url);
      updateProgress((index + 1) / feedUrls.length);
    }
  }

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

  Future<Set<String>?> deleteUnsubscribedPodcastData() =>
      _dao.deleteUnsubscribedPodcastData();
}

Future<Podcast> loadPodcast(String url) => Feed.loadFeed(url: url);
