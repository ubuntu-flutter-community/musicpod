import 'package:collection/collection.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/languages.dart';
import '../../local_audio/data/local_search_result.dart';
import '../../podcasts/data/podcast_genre.dart';
import '../manager/search_manager.dart';
import 'search_type.dart';

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
