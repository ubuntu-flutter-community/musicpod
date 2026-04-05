import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:synchronized/synchronized.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import '../common/view/audio_filter.dart';
import '../common/view/languages.dart';
import '../extensions/date_time_x.dart';
import '../extensions/string_x.dart';
import '../library/library_service.dart';
import '../notifications/notifications_service.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
import 'data/podcast_genre.dart';

@lazySingleton
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
       _libraryService = libraryService {
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
  Search? _search;

  void init({bool forceInit = false}) {
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
  Future<List<PodcastGenre>> loadGenres() async {
    if (_podcastGenreCache.isNotEmpty) {
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

  final _syncLock = Lock();
  Future<void> checkForUpdates({
    Set<String>? feedUrls,
    required String updateMessage,
    required String Function(int length) multiUpdateMessage,
  }) => _syncLock.synchronized(() async {
    await _checkForUpdates(
      feedUrls: feedUrls,
      updateMessage: updateMessage,
      multiUpdateMessage: multiUpdateMessage,
    );
  });

  Future<void> _checkForUpdates({
    Set<String>? feedUrls,
    required String updateMessage,
    required String Function(int length) multiUpdateMessage,
  }) async {
    final newUpdateFeedUrls = <String>{};

    for (final feedUrl in (feedUrls ?? _libraryService.podcasts)) {
      final storedTimeStamp = _libraryService.getPodcastLastUpdated(feedUrl);
      final name = _libraryService.getSubscribedPodcastName(feedUrl);

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
        await _libraryService.addPodcastLastUpdated(
          feedUrl: feedUrl,
          timestamp: feedLastUpdated.toPodcastTimeStamp,
        );
        await findEpisodes(feedUrl: feedUrl);
        await _libraryService.addPodcastUpdate(feedUrl, feedLastUpdated);

        newUpdateFeedUrls.add(feedUrl);
      }
    }

    if (newUpdateFeedUrls.isNotEmpty) {
      final msg = multiUpdateMessage(newUpdateFeedUrls.length);
      _notificationsService.notify(message: msg);
    }
  }

  Future<List<Audio>> findEpisodes({Item? item, String? feedUrl}) async {
    if (item == null && item?.feedUrl == null && feedUrl == null) {
      printMessageInDebugMode('findEpisodes called without feedUrl or item');
      return Future.value([]);
    }

    final url = feedUrl ?? item!.feedUrl!;

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
