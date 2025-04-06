import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/data/podcast_genre.dart';
import '../common/view/languages.dart';
import '../extensions/string_x.dart';
import '../library/library_service.dart';
import '../local_audio/local_audio_service.dart';
import '../podcasts/podcast_service.dart';
import '../radio/radio_service.dart';
import 'search_type.dart';

const _initialAudioType = AudioType.podcast;

class SearchModel extends SafeChangeNotifier {
  SearchModel({
    required RadioService radioService,
    required PodcastService podcastService,
    required LibraryService libraryService,
    required LocalAudioService localAudioService,
  })  : _radioService = radioService,
        _podcastService = podcastService,
        _libraryService = libraryService,
        _localAudioService = localAudioService {
    init();
  }

  final RadioService _radioService;
  final PodcastService _podcastService;
  final LibraryService _libraryService;
  final LocalAudioService _localAudioService;

  void init() {
    _country ??= Country.values.firstWhereOrNull(
      (c) =>
          c.code ==
          (_libraryService.lastCountryCode ??
              WidgetsBinding.instance.platformDispatcher.locale.countryCode
                  ?.toLowerCase()),
    );

    _language ??= Languages.defaultLanguages.firstWhereOrNull(
      (c) => c.isoCode == _libraryService.lastLanguageCode,
    );
  }

  Set<SearchType> _searchTypes = searchTypesFromAudioType(_initialAudioType);
  Set<SearchType> get searchTypes => _searchTypes;
  AudioType _audioType = _initialAudioType;
  AudioType get audioType => _audioType;
  void setAudioType(AudioType? value) {
    if (value == _audioType || value == null) return;
    _audioType = value;
    _searchTypes = searchTypesFromAudioType(_audioType);
    setSearchType(_searchTypes.first);
  }

  SearchType _searchType = searchTypesFromAudioType(_initialAudioType).first;
  SearchType get searchType => _searchType;
  void setSearchType(SearchType value) {
    _searchType = value;
    notifyListeners();
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery(String? value) {
    if (value == _searchQuery) return;
    _podcastLimit = podcastDefaultLimit;
    _radioLimit = _radioDefaultLimit;
    _searchQuery = value;
    notifyListeners();
  }

  SearchResult? _podcastSearchResult;
  SearchResult? get podcastSearchResult => _podcastSearchResult;
  void setPodcastSearchResult(SearchResult? value) {
    _podcastSearchResult = value;
    notifyListeners();
  }

  Country? _country;
  Country? get country => _country;
  void setCountry(Country? value) {
    if (value == _country) return;
    _country = value;
    notifyListeners();
  }

  SimpleLanguage? _language;
  SimpleLanguage? get language => _language;
  void setLanguage(SimpleLanguage? value) {
    if (value == _language) return;
    _language = value;
    notifyListeners();
  }

  List<Tag>? get tags => _radioService.tags;
  Tag? _tag;
  Tag? get tag => _tag;
  void setTag(Tag? value) {
    if (value == _tag) return;
    _tag = value;
    notifyListeners();
  }

  PodcastGenre _podcastGenre = PodcastGenre.all;
  PodcastGenre get podcastGenre => _podcastGenre;
  void setPodcastGenre(PodcastGenre value) {
    if (value == _podcastGenre) return;
    _podcastGenre = value;
    notifyListeners();
  }

  List<PodcastGenre> getPodcastGenres(bool usePodcastIndex) {
    PodcastGenre.values.where((g) => g != podcastGenre).toList();

    const list = PodcastGenre.values;

    return usePodcastIndex
        ? list.where((e) => !e.name.contains('XXXITunesOnly')).toList()
        : list.where((e) => !e.name.contains('XXXPodcastIndexOnly')).toList();
  }

  List<Audio>? _radioSearchResult;
  List<Audio>? get radioSearchResult => _radioSearchResult;
  void setRadioSearchResult(List<Audio>? value) {
    _radioSearchResult = value;
    notifyListeners();
  }

  LocalSearchResult? _localSearchResult;
  LocalSearchResult? get localSearchResult => _localSearchResult;
  void setLocalSearchResult(LocalSearchResult? value) {
    _localSearchResult = value;
    notifyListeners();
  }

  Future<LocalSearchResult?> localSearch(String? query) async {
    await Future.delayed(const Duration(microseconds: 1));
    final search = _localAudioService.search(_searchQuery);
    return LocalSearchResult(
      titles: search?.titles,
      artists: search?.artists,
      albumArtists: search?.albumArtists,
      albums: search?.albums,
      genres: search?.genres,
      playlists: (query != null && query.isNotEmpty)
          ? _libraryService.playlists.keys
              .where(
                (e) => e.toLowerCase().contains(query.toLowerCase()),
              )
              .toList()
          : null,
    );
  }

  static const podcastDefaultLimit = 32;
  int _podcastLimit = podcastDefaultLimit;
  void incrementPodcastLimit(int value) => _podcastLimit += value;

  static const _radioDefaultLimit = 64;
  int _radioLimit = _radioDefaultLimit;
  void incrementRadioLimit(int value) => _radioLimit += value;

  void incrementLimit(int value) => _audioType == AudioType.podcast
      ? incrementPodcastLimit(value)
      : incrementRadioLimit(value);

  bool loading = false;
  set _loading(bool value) {
    loading = value;
    notifyListeners();
  }

  final noNumbers = RegExp(r'^[^0-9]+$');
  Future<Station?> _findSimilarStation(Audio audio) async {
    final searchTags = audio.tags?.where((e) => noNumbers.hasMatch(e));
    if (searchTags == null || searchTags.isEmpty) {
      return null;
    }
    Station? maybe;
    int tries = audio.tags!.length;
    do {
      maybe = (await _radioService.search(
        limit: 500,
        tag: searchTags.elementAt(Random().nextInt(searchTags.length)),
      ))
          ?.where(
            (e) => _areTagsSimilar(
              stationTags: searchTags,
              otherTags: (Audio.fromStation(e).tags ?? [])
                  .where((e) => noNumbers.hasMatch(e)),
            ),
          )
          .lastWhereOrNull((e) => e.stationUUID != audio.uuid);

      tries--;
    } while (tries > 0 && (maybe == null || audio == Audio.fromStation(maybe)));

    return maybe;
  }

  bool _areTagsSimilar({
    required Iterable<String> stationTags,
    required Iterable<String> otherTags,
  }) {
    final matches = <String>{};
    for (var tag in stationTags.map((e) => e.toLowerCase().trim()).toList()) {
      if (otherTags.contains(tag.toLowerCase().trim())) {
        matches.add(tag);
      }
    }

    return switch (stationTags.length) {
      1 || 2 || 3 => matches.isNotEmpty,
      4 || 5 || 6 || 7 || 8 || 9 || 10 => matches.length >= 2,
      _ => matches.length >= 3,
    };
  }

  bool _findingSimilarStation = false;
  bool get findingSimilarStation => _findingSimilarStation;
  set _setFindingSimilarStation(bool value) {
    _findingSimilarStation = value;
    notifyListeners();
  }

  Future<Audio> nextSimilarStation(Audio station) async {
    _setFindingSimilarStation = true;

    Audio? match;
    Station? maybe = await _findSimilarStation(station);
    if (maybe != null) {
      match = Audio.fromStation(maybe);
    } else {
      match = station;
    }

    _setFindingSimilarStation = false;

    return match;
  }

  Future<void> search({
    bool clear = false,
    bool manualFilter = false,
  }) async {
    _loading = true;

    if (clear) {
      switch (_audioType) {
        case AudioType.podcast:
          setPodcastSearchResult(null);
        case AudioType.local:
          setLocalSearchResult(null);
        case AudioType.radio:
          setRadioSearchResult(null);
      }
    }

    return switch (_searchType) {
      SearchType.radioName => await radioNameSearch(_searchQuery)
          .then(
            (v) => setRadioSearchResult(
              _searchQuery == null || _searchQuery!.isEmpty
                  ? null
                  : v?.map((e) => Audio.fromStation(e)).toList(),
            ),
          )
          .then((_) => _loading = false),
      SearchType.radioTag => await _radioService
          .search(tag: _tag?.name, limit: _radioLimit)
          .then(
            (v) => setRadioSearchResult(
              v?.map((e) => Audio.fromStation(e)).toList(),
            ),
          )
          .then((_) => _loading = false),
      SearchType.radioCountry => await _radioService
          .search(country: _country?.name.camelToSentence, limit: _radioLimit)
          .then(
            (v) => setRadioSearchResult(
              v?.map((e) => Audio.fromStation(e)).toList(),
            ),
          )
          .then((_) => _loading = false),
      SearchType.radioLanguage => await _radioService
          .search(
            language: _language?.name.toLowerCase(),
            limit: _radioLimit,
          )
          .then(
            (v) => setRadioSearchResult(
              v?.map((e) => Audio.fromStation(e)).toList(),
            ),
          )
          .then((_) => _loading = false),
      SearchType.podcastTitle => await _podcastService
          .search(
            searchQuery: _searchQuery,
            limit: _podcastLimit,
            country: _country,
            language: _language,
            podcastGenre: _podcastGenre,
          )
          .then((v) => setPodcastSearchResult(v))
          .then((_) => _loading = false),
      _ => await localSearch(_searchQuery).then((v) {
          setLocalSearchResult(v);

          if (!manualFilter) {
            if (localSearchResult?.titles?.isNotEmpty == true) {
              setSearchType(SearchType.localTitle);
            } else if (localSearchResult?.albums?.isNotEmpty == true) {
              setSearchType(SearchType.localAlbum);
            } else if (localSearchResult?.artists?.isNotEmpty == true) {
              setSearchType(SearchType.localArtist);
            }
            // else if (localSearchResult?.albumArtists?.isNotEmpty == true) {
            //   setSearchType(SearchType.localAlbumArtist);
            // }
            else if (localSearchResult?.genres?.isNotEmpty == true) {
              setSearchType(SearchType.localGenreName);
            } else if (localSearchResult?.playlists?.isNotEmpty == true) {
              setSearchType(SearchType.localPlaylists);
            }
          }
        }).then(
          (_) => _loading = false,
        ),
    };
  }

  Future<List<Station>?> radioNameSearch(String? searchQuery) async =>
      _radioService.search(name: searchQuery, limit: _radioLimit);

  List<Station>? _radioCountryChartsPeak;
  List<Station>? get radioCountryChartsPeak => _radioCountryChartsPeak;
  Future<void> radioCountrySearch({int limit = 3}) async {
    _radioCountryChartsPeak =
        await _radioService.search(country: _country?.name, limit: limit);
    notifyListeners();
  }

  SearchResult? _podcastChartsPeak;

  FocusNode fieldFocusNode = FocusNode();
  SearchResult? get podcastChartsPeak => _podcastChartsPeak;
  Future<void> fetchPodcastChartsPeak({int limit = 3}) async {
    _podcastChartsPeak =
        await _podcastService.search(country: _country, limit: limit);
    notifyListeners();
  }
}
