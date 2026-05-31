import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/view/languages.dart';
import '../extensions/string_x.dart';
import '../local_audio/local_audio_service.dart';
import '../local_audio/local_search_result.dart';
import '../podcasts/data/podcast_genre.dart';
import '../podcasts/podcast_service.dart';
import '../radio/radio_service.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
import 'search_timeout_exception.dart';
import 'search_type.dart';

@lazySingleton
class SearchManager {
  SearchManager({
    required RadioService radioService,
    required PodcastService podcastService,
    required LocalAudioService localAudioService,
    required SettingsService settingsService,
  }) : _radioService = radioService,
       _settingsService = settingsService,

       _podcastService = podcastService,
       _localAudioService = localAudioService {
    country.value ??= Country.values.firstWhereOrNull(
      (c) =>
          c.code ==
          (settingsService.getString(SPKeys.lastCountryCode) ??
              WidgetsBinding.instance.platformDispatcher.locale.countryCode
                  ?.toLowerCase()),
    );

    language.value ??= Languages.defaultLanguages.firstWhereOrNull(
      (c) => c.isoCode == settingsService.getString(SPKeys.lastLanguageCode),
    );

    _initialAudioType =
        AudioType.values.firstWhereOrNull(
          (t) =>
              t.name ==
              settingsService.getString(SPKeys.selectedSearchAudioType),
        ) ??
        AudioType.podcast;

    searchTypes = SafeValueNotifier(
      searchTypesFromAudioType(_initialAudioType),
    );

    audioType = SafeValueNotifier(_initialAudioType);

    searchType = SafeValueNotifier(
      searchTypesFromAudioType(_initialAudioType).first,
    );
  }

  final RadioService _radioService;
  final PodcastService _podcastService;
  final LocalAudioService _localAudioService;
  final SettingsService _settingsService;
  late AudioType _initialAudioType;

  final _messageController = StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageController.stream;

  @disposeMethod
  Future<void> dispose() => _messageController.close();

  late SafeValueNotifier<Set<SearchType>> searchTypes;
  late SafeValueNotifier<AudioType> audioType;
  void setAudioType(AudioType? value) {
    if (value == audioType.value || value == null) return;
    audioType.value = value;
    unawaited(
      _settingsService.setValue(
        SPKeys.selectedSearchAudioType,
        audioType.value.name,
      ),
    );
    searchTypes.value = searchTypesFromAudioType(audioType.value);
    setSearchType(searchTypes.value.first);
  }

  late SafeValueNotifier<SearchType> searchType;
  void setSearchType(SearchType value) {
    searchType.value = value;
  }

  SafeValueNotifier<String?> searchQuery = SafeValueNotifier(null);
  void setSearchQuery(String? value) {
    if (value == searchQuery.value) return;
    _podcastLimit = podcastDefaultLimit;
    _radioLimit = _radioDefaultLimit;
    searchQuery.value = value;
  }

  SafeValueNotifier<Country?> country = SafeValueNotifier(null);
  void setCountry(Country? value) {
    if (value == country.value) return;
    country.value = value;
  }

  SafeValueNotifier<SimpleLanguage?> language = SafeValueNotifier(null);
  void setLanguage(SimpleLanguage? value) {
    if (value == language.value) return;
    language.value = value;
  }

  List<Tag>? get tags => _radioService.tags;
  SafeValueNotifier<Tag?> tag = SafeValueNotifier(null);
  void setTag(Tag? value) {
    if (value == tag.value) return;
    tag.value = value;
  }

  SafeValueNotifier<PodcastGenre> podcastGenre = SafeValueNotifier(
    PodcastGenre.all,
  );
  void setPodcastGenre(PodcastGenre value) {
    if (value == podcastGenre.value) return;
    podcastGenre.value = value;
  }

  late final Command<({bool force})?, List<PodcastGenre>>
  loadPodcastGenresCommand = Command.createAsync(
    (param) => _podcastService.loadGenres(force: param?.force ?? false),
    initialValue: _podcastService.cachedPodcastGenres,
  );

  Future<LocalSearchResult?> localSearch(String? query) async {
    final search = _localAudioService.search(searchQuery.value);
    return LocalSearchResult(
      titles: search?.titles,
      artists: search?.artists,
      albums: search?.albums,
      genres: search?.genres,
      playlists: (query != null && query.isNotEmpty)
          ? _localAudioService.playlistIDs
                .where((e) => e.toLowerCase().contains(query.toLowerCase()))
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

  void incrementLimit(int value) => audioType.value == AudioType.podcast
      ? incrementPodcastLimit(value)
      : incrementRadioLimit(value);

  late final Command<Audio, Audio?> findSimilarStationCommand =
      Command.createAsync(_radioService.findSimilarStation, initialValue: null);

  SafeValueNotifier<Attribute> podcastSearchAttribute = SafeValueNotifier(
    Attribute.none,
  );
  void setPodcastSearchAttribute(Attribute value) {
    if (value == podcastSearchAttribute.value) return;
    podcastSearchAttribute.value = value;
  }

  void search({bool clear = false, bool manualFilter = false}) =>
      searchCommand.run((clear: clear, manualFilter: manualFilter));

  Future<void> refresh() =>
      searchCommand.runAsync((clear: true, manualFilter: false));

  late final Command<({bool clear, bool manualFilter}), void> searchCommand =
      Command.createAsyncNoResult(
        (param) =>
            _search(clear: param.clear, manualFilter: param.manualFilter),
      );

  Future<void> _search({bool clear = false, bool manualFilter = false}) async {
    if (clear) {
      switch (audioType.value) {
        case AudioType.podcast:
          _setPodcastSearchResult(null);
        case AudioType.local:
          _setLocalSearchResult(null);
        case AudioType.radio:
          _setRadioSearchResult(null);
      }
    }

    return (switch (searchType.value) {
          SearchType.radioName =>
            _radioService
                .search(name: searchQuery.value, limit: _radioLimit)
                .then(
                  (v) => _setRadioSearchResult(
                    searchQuery.value == null || searchQuery.value!.isEmpty
                        ? null
                        : v,
                  ),
                ),
          SearchType.radioTag =>
            _radioService
                .search(tag: tag.value?.name, limit: _radioLimit)
                .then((v) => _setRadioSearchResult(v)),
          SearchType.radioCountry =>
            _radioService
                .search(
                  country: country.value?.name.camelToSentence,
                  limit: _radioLimit,
                )
                .then((v) => _setRadioSearchResult(v)),
          SearchType.radioLanguage =>
            _radioService
                .search(
                  language: language.value?.name.toLowerCase(),
                  limit: _radioLimit,
                )
                .then((v) => _setRadioSearchResult(v)),
          SearchType.podcastTitle =>
            _podcastService
                .search(
                  searchQuery: searchQuery.value,
                  limit: _podcastLimit,
                  country: country.value,
                  language: language.value,
                  podcastGenre: podcastGenre.value,
                  attribute: podcastSearchAttribute.value,
                )
                .then((v) => _setPodcastSearchResult(v)),
          _ => localSearch(searchQuery.value).then((v) {
            _setLocalSearchResult(v);

            if (!manualFilter) {
              if (localSearchResult.value?.titles?.isNotEmpty == true) {
                setSearchType(SearchType.localTitle);
              } else if (localSearchResult.value?.albums?.isNotEmpty == true) {
                setSearchType(SearchType.localAlbum);
              } else if (localSearchResult.value?.artists?.isNotEmpty == true) {
                setSearchType(SearchType.localArtist);
              }
              // else if (localSearchResult?.albumArtists?.isNotEmpty == true) {
              //   setSearchType(SearchType.localAlbumArtist);
              // }
              else if (localSearchResult.value?.genres?.isNotEmpty == true) {
                setSearchType(SearchType.localGenreName);
              } else if (localSearchResult.value?.playlists?.isNotEmpty ==
                  true) {
                setSearchType(SearchType.localPlaylists);
              }
            }
          }),
        })
        .timeout(
          const Duration(seconds: SearchTimeoutException.searchTimeoutSeconds),
          onTimeout: () {
            throw SearchTimeoutException();
          },
        )
        .onError((e, st) {
          if (e == null) return;
          _messageController.addError(e);
        });
  }

  final radioSearchResult = SafeValueNotifier<List<Audio>?>(null);
  void _setRadioSearchResult(List<Audio>? value) =>
      radioSearchResult.value = value;

  final localSearchResult = SafeValueNotifier<LocalSearchResult?>(null);
  void _setLocalSearchResult(LocalSearchResult? value) =>
      localSearchResult.value = value;

  final podcastSearchResult = SafeValueNotifier<SearchResult?>(null);
  void _setPodcastSearchResult(SearchResult? value) {
    podcastSearchResult.value = value;
  }

  Future<List<Audio>?> radioNameSearch(String? searchQuery) async =>
      _radioService.search(name: searchQuery, limit: _radioLimit);
}
