import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/data/podcast_genre.dart';
import '../common/view/languages.dart';
import '../extensions/string_x.dart';
import '../library/library_service.dart';
import '../local_audio/local_audio_model.dart';
import '../podcasts/podcast_service.dart';
import '../radio/radio_service.dart';
import 'local_audio_search_result.dart';
import 'search_type.dart';

const _initialAudioType = AudioType.radio;

class SearchModel extends SafeChangeNotifier {
  SearchModel({
    required RadioService radioService,
    required PodcastService podcastService,
    required LocalAudioModel localAudioModel,
    required LibraryService libraryService,
  })  : _radioService = radioService,
        _podcastService = podcastService,
        _localAudioModel = localAudioModel,
        _libraryService = libraryService;

  final RadioService _radioService;
  final PodcastService _podcastService;
  // TODO: replace with service when all is migrated
  final LocalAudioModel _localAudioModel;
  final LibraryService _libraryService;

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
  void setAudioType(AudioType value) {
    if (value == _audioType) return;
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

  LocalAudioSearchResult? _localAudioSearchResult;
  LocalAudioSearchResult? get localAudioSearchResult => _localAudioSearchResult;
  void setLocalAudioSearchResult(LocalAudioSearchResult? value) {
    _localAudioSearchResult = value;
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

  List<PodcastGenre> get sortedGenres {
    final notSelected =
        PodcastGenre.values.where((g) => g != podcastGenre).toList();

    return [podcastGenre, ...notSelected];
  }

  List<Audio>? _radioSearchResult;
  List<Audio>? get radioSearchResult => _radioSearchResult;
  void setRadioSearchResult(List<Audio>? value) {
    _radioSearchResult = value;
    notifyListeners();
  }

  void setSearchQuery(String? value) {
    if (value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  int _podcastLimit = 20;
  void incrementPodcastLimit(int value) => _podcastLimit += value;

  bool loading = false;
  set _loading(bool value) {
    loading = value;
    notifyListeners();
  }

  Future<void> search({bool clear = false}) async {
    _loading = true;

    if (clear) {
      switch (_audioType) {
        case AudioType.podcast:
          setPodcastSearchResult(null);
        case AudioType.local:
          setLocalAudioSearchResult(null);
        case AudioType.radio:
          setRadioSearchResult(null);
      }
    }

    return switch (_searchType) {
      SearchType.radioName => await _radioService
          .search(name: _searchQuery)
          .then(
            (v) => setRadioSearchResult(
              v?.map((e) => Audio.fromStation(e)).toList(),
            ),
          )
          .then((_) => _loading = false),
      SearchType.radioTag => await _radioService
          .search(tag: _tag?.name)
          .then(
            (v) => setRadioSearchResult(
              v?.map((e) => Audio.fromStation(e)).toList(),
            ),
          )
          .then((_) => _loading = false),
      SearchType.radioCountry => await _radioService
          .search(country: _country?.name.camelToSentence)
          .then(
            (v) => setRadioSearchResult(
              v?.map((e) => Audio.fromStation(e)).toList(),
            ),
          )
          .then((_) => _loading = false),
      SearchType.radioLanguage => await _radioService
          .search(language: _language?.name.toLowerCase())
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
      SearchType.localArtist ||
      SearchType.localTitle ||
      SearchType.localArtist ||
      SearchType.localGenreName =>
        localSearch(_localAudioModel.audios),
      _ => Future.value().then((_) => _loading = false)
    };
  }

  LocalAudioSearchResult? localSearch(Set<Audio>? audios) {
    if (_searchQuery == null) return null;
    if (_searchQuery?.isEmpty == true) {
      (
        titlesSearchResult: {},
        albumSearchResult: {},
        artistsSearchResult: {},
        genresSearchResult: {},
      );
    }

    final allAlbumsFindings = audios?.where(
      (audio) =>
          audio.album?.isNotEmpty == true &&
          audio.album!.toLowerCase().contains(_searchQuery!.toLowerCase()),
    );

    final albumsResult = <Audio>{};
    if (allAlbumsFindings != null) {
      for (var a in allAlbumsFindings) {
        if (albumsResult.none((element) => element.album == a.album)) {
          albumsResult.add(a);
        }
      }
    }

    final allGenresFindings = audios?.where(
      (audio) =>
          audio.genre?.isNotEmpty == true &&
          audio.genre!.toLowerCase().contains(_searchQuery!.toLowerCase()),
    );

    final genreFindings = <Audio>{};
    if (allGenresFindings != null) {
      for (var a in allGenresFindings) {
        if (genreFindings.none((element) => element.genre == a.genre)) {
          genreFindings.add(a);
        }
      }
    }

    final allArtistFindings = audios?.where(
      (audio) =>
          audio.artist?.isNotEmpty == true &&
          audio.artist!.toLowerCase().contains(_searchQuery!.toLowerCase()),
    );
    final artistsResult = <Audio>{};
    if (allArtistFindings != null) {
      for (var a in allArtistFindings) {
        if (artistsResult.none(
          (e) => e.artist == a.artist,
        )) {
          artistsResult.add(a);
        }
      }
    }

    return (
      titlesSearchResult: Set.from(
        audios?.where(
              (audio) =>
                  audio.title?.isNotEmpty == true &&
                  audio.title!
                      .toLowerCase()
                      .contains(_searchQuery!.toLowerCase()),
            ) ??
            <Audio>[],
      ),
      albumSearchResult: albumsResult,
      artistsSearchResult: artistsResult,
      genresSearchResult: genreFindings,
    );
  }
}
