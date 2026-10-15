import 'dart:async';

import 'package:collection/collection.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/languages.dart';
import '../../dependencies.dart';
import '../../extensions/platform_x.dart';
import '../../extensions/ref_x.dart';
import '../../extensions/string_x.dart';
import '../../local_audio/service/local_audio_service.dart';
import '../../podcasts/data/podcast_genre.dart';
import '../../podcasts/service/podcast_service.dart';
import '../../radio/service/radio_service.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/service/settings_service.dart';
import '../data/search_state.dart';
import '../data/search_timeout_exception.dart';
import '../data/search_type.dart';

part 'search_manager.g.dart';

@riverpod
class SearchManager extends _$SearchManager {
  SearchManager({
    RadioService? radioService,
    PodcastService? podcastService,
    LocalAudioService? localAudioService,
    SettingsService? settingsService,
  }) : _radioServiceOverride = radioService,
       _podcastServiceOverride = podcastService,
       _localAudioServiceOverride = localAudioService,
       _settingsServiceOverride = settingsService;

  final RadioService? _radioServiceOverride;
  final PodcastService? _podcastServiceOverride;
  final LocalAudioService? _localAudioServiceOverride;
  final SettingsService? _settingsServiceOverride;

  RadioService get _radioService => _radioServiceOverride ?? di<RadioService>();
  PodcastService get _podcastService =>
      _podcastServiceOverride ?? di<PodcastService>();
  LocalAudioService get _localAudioService =>
      _localAudioServiceOverride ?? di<LocalAudioService>();
  SettingsService get _settingsService =>
      _settingsServiceOverride ?? di<SettingsService>();

  static const podcastDefaultLimit = 32;
  static const radioDefaultLimit = 64;

  int _searchExecutionId = 0;

  @override
  SearchState build() {
    ref.cacheFor(const Duration(seconds: 10));
    final country = Country.values.firstWhereOrNull(
      (c) =>
          c.code ==
          (_settingsService.getString(SPKeys.lastCountryCode) ??
              systemCountryCode),
    );

    final language = Languages.defaultLanguages.firstWhereOrNull(
      (c) => c.isoCode == _settingsService.getString(SPKeys.lastLanguageCode),
    );

    final initialAudioType =
        AudioType.values.firstWhereOrNull(
          (t) =>
              t.name ==
              _settingsService.getString(SPKeys.selectedSearchAudioType),
        ) ??
        AudioType.podcast;

    final searchTypes = searchTypesFromAudioType(initialAudioType);

    return SearchState(
      audioType: initialAudioType,
      searchTypes: searchTypes,
      searchType: searchTypes.first,
      country: country,
      language: language,
      podcastGenre: PodcastGenre.all,
      podcastSearchAttribute: Attribute.none,
      podcastLimit: podcastDefaultLimit,
      radioLimit: radioDefaultLimit,
    );
  }

  AudioType get audioType => state.audioType;

  void setAudioType(AudioType? value) {
    if (value == null || value == state.audioType) return;
    unawaited(
      _settingsService.setValue(SPKeys.selectedSearchAudioType, value.name),
    );
    final newSearchTypes = searchTypesFromAudioType(value);
    state = state.copyWith(
      audioType: value,
      searchTypes: newSearchTypes,
      searchType: newSearchTypes.first,
    );
  }

  void setSearchType(SearchType value) {
    if (value == state.searchType) return;
    state = state.copyWith(searchType: value);
  }

  void setSearchQuery(String? value) {
    if (value == state.searchQuery) return;
    state = state.copyWith(
      podcastLimit: podcastDefaultLimit,
      radioLimit: radioDefaultLimit,
      searchQuery: () => value,
    );
  }

  void setCountry(Country? value) {
    if (value == state.country) return;
    state = state.copyWith(country: () => value);
  }

  void setLanguage(SimpleLanguage? value) {
    if (value == state.language) return;
    state = state.copyWith(language: () => value);
  }

  void setTag(Tag? value) {
    if (value == state.tag) return;
    state = state.copyWith(tag: () => value);
  }

  void setPodcastGenre(PodcastGenre value) {
    if (value == state.podcastGenre) return;
    state = state.copyWith(podcastGenre: value);
  }

  void setPodcastSearchAttribute(Attribute value) {
    if (value == state.podcastSearchAttribute) return;
    state = state.copyWith(podcastSearchAttribute: value);
  }

  void incrementPodcastLimit(int value) {
    state = state.copyWith(podcastLimit: state.podcastLimit + value);
  }

  void incrementRadioLimit(int value) {
    state = state.copyWith(radioLimit: state.radioLimit + value);
  }

  void incrementLimit(int value) => state.audioType == AudioType.podcast
      ? incrementPodcastLimit(value)
      : incrementRadioLimit(value);

  void search({bool clear = false, bool manualFilter = false}) =>
      unawaited(_search(clear: clear, manualFilter: manualFilter));

  Future<void> refresh() => _search(clear: true, manualFilter: false);

  Future<void> _search({bool clear = false, bool manualFilter = false}) async {
    final executionId = ++_searchExecutionId;

    state = state.copyWith(
      isLoading: true,
      error: () => null,
      stackTrace: () => null,
      radioSearchResult: clear && state.audioType == AudioType.radio
          ? () => null
          : null,
      podcastSearchResult: clear && state.audioType == AudioType.podcast
          ? () => null
          : null,
      localSearchResult: clear && state.audioType == AudioType.local
          ? () => null
          : null,
    );

    try {
      final currentSearchType = state.searchType;
      final currentQuery = state.searchQuery;
      final currentTag = state.tag;
      final currentCountry = state.country;
      final currentLanguage = state.language;
      final currentRadioLimit = state.radioLimit;
      final currentPodcastLimit = state.podcastLimit;
      final currentPodcastGenre = state.podcastGenre;
      final currentAttribute = state.podcastSearchAttribute;

      final Future<void> searchFuture = switch (currentSearchType) {
        SearchType.radioName =>
          _radioService
              .search(name: currentQuery, limit: currentRadioLimit)
              .then((v) {
                if (executionId != _searchExecutionId) return;
                state = state.copyWith(
                  radioSearchResult: () =>
                      currentQuery == null || currentQuery.isEmpty ? null : v,
                );
              }),
        SearchType.radioTag =>
          _radioService
              .search(tag: currentTag?.name, limit: currentRadioLimit)
              .then((v) {
                if (executionId != _searchExecutionId) return;
                state = state.copyWith(radioSearchResult: () => v);
              }),
        SearchType.radioCountry =>
          _radioService
              .search(
                country: currentCountry?.name.camelToSentence,
                limit: currentRadioLimit,
              )
              .then((v) {
                if (executionId != _searchExecutionId) return;
                state = state.copyWith(radioSearchResult: () => v);
              }),
        SearchType.radioLanguage =>
          _radioService
              .search(
                language: currentLanguage?.name.toLowerCase(),
                limit: currentRadioLimit,
              )
              .then((v) {
                if (executionId != _searchExecutionId) return;
                state = state.copyWith(radioSearchResult: () => v);
              }),
        SearchType.podcastTitle =>
          _podcastService
              .search(
                searchQuery: currentQuery,
                limit: currentPodcastLimit,
                country: currentCountry,
                language: currentLanguage,
                podcastGenre: currentPodcastGenre,
                attribute: currentAttribute,
              )
              .then((v) {
                if (executionId != _searchExecutionId) return;
                state = state.copyWith(podcastSearchResult: () => v);
              }),
        _ => _localAudioService.search(currentQuery ?? '').then((v) {
          if (executionId != _searchExecutionId) return;
          SearchType nextSearchType = currentSearchType;
          if (!manualFilter) {
            if (v?.titles?.isNotEmpty == true) {
              nextSearchType = SearchType.localTitle;
            } else if (v?.albums?.isNotEmpty == true) {
              nextSearchType = SearchType.localAlbum;
            } else if (v?.artists?.isNotEmpty == true) {
              nextSearchType = SearchType.localArtist;
            } else if (v?.genres?.isNotEmpty == true) {
              nextSearchType = SearchType.localGenreName;
            } else if (v?.playlists?.isNotEmpty == true) {
              nextSearchType = SearchType.localPlaylists;
            }
          }
          state = state.copyWith(
            localSearchResult: () => v,
            searchType: nextSearchType,
          );
        }),
      };

      await searchFuture.timeout(
        const Duration(seconds: SearchTimeoutException.searchTimeoutSeconds),
        onTimeout: () {
          throw SearchTimeoutException();
        },
      );

      if (executionId != _searchExecutionId) return;
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      if (executionId != _searchExecutionId) return;
      state = state.copyWith(
        isLoading: false,
        error: () => e,
        stackTrace: () => st,
      );
    }
  }

  Future<List<Audio>?> radioNameSearch(String? searchQuery) async =>
      _radioService.search(name: searchQuery, limit: state.radioLimit);
}
