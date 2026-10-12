import 'dart:async';

import 'package:collection/collection.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/logging.dart';
import '../../common/view/languages.dart';
import '../../dependencies.dart';
import '../../extensions/platform_x.dart';
import '../../extensions/string_x.dart';
import '../../local_audio/data/local_search_result.dart';
import '../../local_audio/service/local_audio_service.dart';
import '../../podcasts/data/podcast_genre.dart';
import '../../podcasts/service/podcast_service.dart';
import '../../radio/service/radio_service.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/service/settings_service.dart';
import '../data/search_timeout_exception.dart';
import '../data/search_type.dart';

part 'search_manager.g.dart';

class SearchState {
  const SearchState({
    required this.audioType,
    required this.searchTypes,
    required this.searchType,
    this.searchQuery,
    this.country,
    this.language,
    this.tag,
    this.podcastGenre = PodcastGenre.all,
    this.podcastSearchAttribute = Attribute.none,
    this.podcastLimit = SearchManager.podcastDefaultLimit,
    this.radioLimit = SearchManager.radioDefaultLimit,
    this.radioSearchResult,
    this.localSearchResult,
    this.podcastSearchResult,
    this.isLoading = false,
    this.error,
    this.stackTrace,
  });

  final AudioType audioType;
  final Set<SearchType> searchTypes;
  final SearchType searchType;
  final String? searchQuery;
  final Country? country;
  final SimpleLanguage? language;
  final Tag? tag;
  final PodcastGenre podcastGenre;
  final Attribute podcastSearchAttribute;
  final int podcastLimit;
  final int radioLimit;
  final List<Audio>? radioSearchResult;
  final LocalSearchResult? localSearchResult;
  final SearchResult? podcastSearchResult;
  final bool isLoading;
  final Object? error;
  final StackTrace? stackTrace;

  SearchState copyWith({
    AudioType? audioType,
    Set<SearchType>? searchTypes,
    SearchType? searchType,
    String? Function()? searchQuery,
    Country? Function()? country,
    SimpleLanguage? Function()? language,
    Tag? Function()? tag,
    PodcastGenre? podcastGenre,
    Attribute? podcastSearchAttribute,
    int? podcastLimit,
    int? radioLimit,
    List<Audio>? Function()? radioSearchResult,
    LocalSearchResult? Function()? localSearchResult,
    SearchResult? Function()? podcastSearchResult,
    bool? isLoading,
    Object? Function()? error,
    StackTrace? Function()? stackTrace,
  }) {
    return SearchState(
      audioType: audioType ?? this.audioType,
      searchTypes: searchTypes ?? this.searchTypes,
      searchType: searchType ?? this.searchType,
      searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
      country: country != null ? country() : this.country,
      language: language != null ? language() : this.language,
      tag: tag != null ? tag() : this.tag,
      podcastGenre: podcastGenre ?? this.podcastGenre,
      podcastSearchAttribute:
          podcastSearchAttribute ?? this.podcastSearchAttribute,
      podcastLimit: podcastLimit ?? this.podcastLimit,
      radioLimit: radioLimit ?? this.radioLimit,
      radioSearchResult: radioSearchResult != null
          ? radioSearchResult()
          : this.radioSearchResult,
      localSearchResult: localSearchResult != null
          ? localSearchResult()
          : this.localSearchResult,
      podcastSearchResult: podcastSearchResult != null
          ? podcastSearchResult()
          : this.podcastSearchResult,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      stackTrace: stackTrace != null ? stackTrace() : this.stackTrace,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchState &&
        other.audioType == audioType &&
        const SetEquality().equals(other.searchTypes, searchTypes) &&
        other.searchType == searchType &&
        other.searchQuery == searchQuery &&
        other.country == country &&
        other.language == language &&
        other.tag == tag &&
        other.podcastGenre == podcastGenre &&
        other.podcastSearchAttribute == podcastSearchAttribute &&
        other.podcastLimit == podcastLimit &&
        other.radioLimit == radioLimit &&
        const ListEquality().equals(
          other.radioSearchResult,
          radioSearchResult,
        ) &&
        other.localSearchResult == localSearchResult &&
        other.podcastSearchResult == podcastSearchResult &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.stackTrace == stackTrace;
  }

  @override
  int get hashCode => Object.hashAll([
    audioType,
    Object.hashAll(searchTypes),
    searchType,
    searchQuery,
    country,
    language,
    tag,
    podcastGenre,
    podcastSearchAttribute,
    podcastLimit,
    radioLimit,
    radioSearchResult == null ? null : Object.hashAll(radioSearchResult!),
    localSearchResult,
    podcastSearchResult,
    isLoading,
    error,
    stackTrace,
  ]);
}

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
    Logger.o(tag: '$SearchManager');

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

  // Getters for convenient access
  AudioType get audioType => state.audioType;
  SearchType get searchType => state.searchType;
  Set<SearchType> get searchTypes => state.searchTypes;
  String? get searchQuery => state.searchQuery;
  Country? get country => state.country;
  SimpleLanguage? get language => state.language;
  Tag? get tag => state.tag;
  PodcastGenre get podcastGenre => state.podcastGenre;
  Attribute get podcastSearchAttribute => state.podcastSearchAttribute;
  int get podcastLimit => state.podcastLimit;
  int get radioLimit => state.radioLimit;
  List<Audio>? get radioSearchResult => state.radioSearchResult;
  LocalSearchResult? get localSearchResult => state.localSearchResult;
  SearchResult? get podcastSearchResult => state.podcastSearchResult;
  bool get isLoading => state.isLoading;
  Object? get error => state.error;
  StackTrace? get stackTrace => state.stackTrace;

  void setAudioType(AudioType? value) {
    if (value == null || value == state.audioType) return;
    unawaited(
      _settingsService.setValue(
        SPKeys.selectedSearchAudioType,
        value.name,
      ),
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

  Future<void> refresh() =>
      _search(clear: true, manualFilter: false);

  Future<void> _search({bool clear = false, bool manualFilter = false}) async {
    final executionId = ++_searchExecutionId;

    state = state.copyWith(
      isLoading: true,
      error: () => null,
      stackTrace: () => null,
      radioSearchResult:
          clear && state.audioType == AudioType.radio ? () => null : null,
      podcastSearchResult:
          clear && state.audioType == AudioType.podcast ? () => null : null,
      localSearchResult:
          clear && state.audioType == AudioType.local ? () => null : null,
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
        SearchType.radioName => _radioService
            .search(name: currentQuery, limit: currentRadioLimit)
            .then((v) {
              if (executionId != _searchExecutionId) return;
              state = state.copyWith(
                radioSearchResult: () =>
                    currentQuery == null || currentQuery.isEmpty ? null : v,
              );
            }),
        SearchType.radioTag => _radioService
            .search(tag: currentTag?.name, limit: currentRadioLimit)
            .then((v) {
              if (executionId != _searchExecutionId) return;
              state = state.copyWith(radioSearchResult: () => v);
            }),
        SearchType.radioCountry => _radioService
            .search(
              country: currentCountry?.name.camelToSentence,
              limit: currentRadioLimit,
            )
            .then((v) {
              if (executionId != _searchExecutionId) return;
              state = state.copyWith(radioSearchResult: () => v);
            }),
        SearchType.radioLanguage => _radioService
            .search(
              language: currentLanguage?.name.toLowerCase(),
              limit: currentRadioLimit,
            )
            .then((v) {
              if (executionId != _searchExecutionId) return;
              state = state.copyWith(radioSearchResult: () => v);
            }),
        SearchType.podcastTitle => _podcastService
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
