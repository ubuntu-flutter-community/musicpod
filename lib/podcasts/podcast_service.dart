import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:podcast_search/podcast_search.dart';

import '../common/data/audio.dart';
import '../common/data/podcast_genre.dart';
import '../common/logging.dart';
import '../common/view/audio_filter.dart';
import '../common/view/languages.dart';
import '../extensions/date_time_x.dart';
import '../library/library_service.dart';
import '../notifications/notifications_service.dart';
import '../settings/settings_service.dart';

class PodcastService {
  final NotificationsService _notificationsService;
  final SettingsService _settingsService;
  final LibraryService _libraryService;
  PodcastService({
    required NotificationsService notificationsService,
    required SettingsService settingsService,
    required LibraryService libraryService,
  }) : _notificationsService = notificationsService,
       _settingsService = settingsService,
       _libraryService = libraryService;

  SearchResult? _searchResult;
  Search? _search;

  Future<void> init({bool forceInit = false}) async {
    if (_search == null || forceInit) {
      _search = Search(
        searchProvider:
            _settingsService.usePodcastIndex == true &&
                _settingsService.podcastIndexApiKey != null &&
                _settingsService.podcastIndexApiSecret != null
            ? PodcastIndexProvider(
                key: _settingsService.podcastIndexApiKey!,
                secret: _settingsService.podcastIndexApiSecret!,
              )
            : const ITunesProvider(),
      );
    }
  }

  String? _previousQuery;
  Future<SearchResult?> search({
    String? searchQuery,
    PodcastGenre podcastGenre = PodcastGenre.all,
    Country? country,
    SimpleLanguage? language,
    int limit = 10,
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
        );
      }
    } catch (e) {
      printMessageInDebugMode(e);
      return _searchResult;
    }

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

  bool _updateLock = false;

  Future<void> updatePodcasts({
    Set<String>? feedUrls,
    required String updateMessage,
  }) async {
    if (_updateLock) return;
    _updateLock = true;

    for (final feedUrl in (feedUrls ?? _libraryService.podcasts)) {
      DateTime? feedLastUpdated;
      try {
        feedLastUpdated = await Feed.feedLastUpdated(url: feedUrl);
      } on Exception catch (e) {
        printMessageInDebugMode(e);
      }
      if (feedLastUpdated == null) continue;

      final storedTimeStamp = _libraryService.getPodcastLastUpdated(feedUrl);
      if (storedTimeStamp == null ||
          feedLastUpdated.podcastTimeStamp != storedTimeStamp) {
        await findEpisodes(feedUrl: feedUrl, loadFromCache: false);
        _libraryService.addPodcastUpdate(feedUrl, feedLastUpdated);
        final updateMessageSuffix =
            '${_episodeCache[feedUrl]?.firstOrNull?.album != null ? ' ${_episodeCache[feedUrl]?.firstOrNull?.album}' : ''}';
        _notificationsService.notify(
          message: updateMessage + updateMessageSuffix,
        );
      }
    }

    _updateLock = false;
  }

  List<Audio>? getPodcastEpisodesFromCache(String? feedUrl) =>
      _episodeCache[feedUrl];
  Map<String, List<Audio>> _episodeCache = {};
  Map<String, DateTime?> _lastUpdatedCache = {};
  DateTime? getLastModifiedFromCache(String feedUrl) =>
      _lastUpdatedCache[feedUrl];
  Future<List<Audio>> findEpisodes({
    Item? item,
    String? feedUrl,
    bool storeCache = true,
    bool loadFromCache = true,
    bool addUpdates = false,
  }) async {
    if (item == null && item?.feedUrl == null && feedUrl == null) {
      printMessageInDebugMode('findEpisodes called without feedUrl or item');
      return Future.value([]);
    }

    final url = feedUrl ?? item!.feedUrl!;

    if (_episodeCache.containsKey(url) && loadFromCache) {
      return _episodeCache[url]!;
    }

    final Podcast? podcast = await compute(loadPodcast, url);
    if (podcast?.image != null) {
      _libraryService.addSubscribedPodcastImage(
        feedUrl: url,
        imageUrl: podcast!.image!,
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

    if (storeCache) {
      _episodeCache[url] = episodes;
      _lastUpdatedCache[url] = podcast?.dateTimeModified;
    }

    if (addUpdates) {
      if (podcast?.dateTimeModified != null) {
        final storedTimeStamp = _libraryService.getPodcastLastUpdated(url);
        if (storedTimeStamp == null ||
            podcast?.dateTimeModified?.podcastTimeStamp != storedTimeStamp) {
          _libraryService.addPodcastUpdate(url, podcast?.dateTimeModified);
        }
      }
    }

    return episodes;
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
