import 'dart:async';

import 'package:podcast_search/podcast_search.dart';

import '../common/data/audio.dart';
import '../common/data/podcast_genre.dart';
import '../common/view/audio_filter.dart';
import '../common/view/languages.dart';
import '../notifications/notifications_service.dart';
import '../settings/settings_service.dart';
import 'podcast_utils.dart';

class PodcastService {
  final NotificationsService _notificationsService;
  final SettingsService _settingsService;
  PodcastService({
    required NotificationsService notificationsService,
    required SettingsService settingsService,
  })  : _notificationsService = notificationsService,
        _settingsService = settingsService;

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

  Future<SearchResult?> search({
    String? searchQuery,
    PodcastGenre podcastGenre = PodcastGenre.all,
    Country? country,
    SimpleLanguage? language,
    int limit = 10,
  }) async {
    SearchResult? result;
    String? error;
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
      error = e.toString();
    }

    if (result != null && result.successful) {
      _searchResult = result;
    } else {
      _searchResult =
          SearchResult.fromError(lastError: error ?? 'Something went wrong');
    }
    return _searchResult;
  }

  Future<void> updatePodcasts({
    required Map<String, Set<Audio>> oldPodcasts,
    required void Function(String name, Set<Audio> audios) updatePodcast,
    required String updateMessage,
  }) async {
    for (final old in oldPodcasts.entries) {
      if (old.value.isNotEmpty) {
        final list = old.value.toList();
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

            updatePodcast(old.key, audios);
            _notificationsService.notify(
              message: '$updateMessage ${firstOld.album ?? old.value}',
            );
          });
        }
      }
    }
  }
}
