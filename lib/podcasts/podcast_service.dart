import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:podcast_search/podcast_search.dart';

import '../common/data/audio.dart';
import '../common/data/podcast_genre.dart';
import '../common/logging.dart';
import '../common/view/audio_filter.dart';
import '../common/view/languages.dart';
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
  })  : _notificationsService = notificationsService,
        _settingsService = settingsService,
        _libraryService = libraryService;

  SearchResult? _searchResult;
  Search? _search;

  Future<void> init({bool forceInit = false}) async {
    if (_search == null || forceInit) {
      _search = Search(
        searchProvider: _settingsService.usePodcastIndex == true &&
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
    Map<String, List<Audio>>? oldPodcasts,
    String? updateMessage,
  }) async {
    if (_updateLock) return;
    _updateLock = true;
    for (final old in (oldPodcasts ?? _libraryService.podcasts).entries) {
      if (old.value.isNotEmpty) {
        final list = old.value;
        sortListByAudioFilter(
          audioFilter: AudioFilter.year,
          audios: list,
          descending: true,
        );
        final firstOld = list.firstOrNull;

        if (firstOld?.website != null) {
          await findEpisodes(
            feedUrl: firstOld!.website!,
          ).then((audios) {
            if (firstOld.year != null &&
                    audios.firstOrNull?.year == firstOld.year ||
                audios.isEmpty) return;

            _libraryService.updatePodcast(old.key, audios);
            if (updateMessage != null) {
              _notificationsService.notify(
                message: '$updateMessage ${firstOld.album ?? old.value}',
              );
            }
          });
        }
      }
    }
    _updateLock = false;
  }

  Future<List<Audio>> findEpisodes({
    required String feedUrl,
    String? itemImageUrl,
    String? genre,
  }) async {
    final Podcast? podcast = await compute(loadPodcast, feedUrl);
    final episodes = podcast?.episodes
            .where((e) => e.contentUrl != null)
            .map(
              (e) => Audio.fromPodcast(
                episode: e,
                podcast: podcast,
                itemImageUrl: itemImageUrl,
                genre: genre,
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
    return await Podcast.loadFeed(
      url: url,
    );
  } catch (e) {
    return null;
  }
}
