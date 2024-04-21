import 'dart:async';

import 'package:collection/collection.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../data.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../string_x.dart';
import '../common/languages.dart';
import 'view/radio_search.dart';
import 'radio_service.dart';

class RadioModel extends SafeChangeNotifier {
  final RadioService _radioService;
  final LibraryService _libraryService;

  RadioModel({
    required RadioService radioService,
    required LibraryService libraryService,
  })  : _radioService = radioService,
        _libraryService = libraryService;

  Country? _country;
  Country? get country => _country;
  void setCountry(Country? value) {
    if (value == _country) return;
    _country = value;
    setSearchQuery(search: RadioSearch.country);
  }

  List<Country> get sortedCountries {
    if (_country == null) return Country.values;
    final notSelected =
        Country.values.where((c) => c != _country).toList().sorted(
              (a, b) => a.name.compareTo(b.name),
            );
    final list = <Country>[_country!, ...notSelected];

    return list;
  }

  List<Tag>? get tags => _radioService.tags;
  Tag? _tag;
  Tag? get tag => _tag;
  void setTag(Tag? value) {
    if (value == _tag) return;
    _tag = value;
    setSearchQuery(search: RadioSearch.tag);
  }

  SimpleLanguage? _language;
  SimpleLanguage? get language => _language;
  void setLanguage(SimpleLanguage? value) {
    if (value == _language) return;
    _language = value;
    setSearchQuery(search: RadioSearch.language);
  }

  Future<Set<Audio>?> getStations({
    required RadioSearch radioSearch,
    required String? query,
  }) async {
    final stations = switch (radioSearch) {
      RadioSearch.tag => await _radioService.getStations(tag: query),
      RadioSearch.country => await _radioService.getStations(
          country: query?.camelToSentence(),
        ),
      RadioSearch.name => await _radioService.getStations(name: query),
      RadioSearch.state => await _radioService.getStations(state: query),
      RadioSearch.language => await _radioService.getStations(language: query),
    };

    if (stations == null) return null;

    if (stations.isEmpty) {
      return <Audio>{};
    }

    return Set.from(
      stations.map((e) => Audio.fromStation(e)),
    );
  }

// TODO: use when radio audios are played
  Future<void> clickStation(Audio station) async {
    if (station.description != null) {
      return await _radioService.clickStation(station.description!);
    }
  }

  // TODO: use in state autocomplete depending on [country]
  Future<List<State>?> loadStates(String country) async {
    return await _radioService.loadStates(country);
  }

  String? _connectedHost;
  String? get connectedHost => _connectedHost;
  Future<String?> init({
    String? countryCode,
    int index = 0,
  }) async {
    _connectedHost ??= await _radioService.init();

    final lastFav = _libraryService.lastRadioTag;

    _country ??= Country.values.firstWhereOrNull(
      (c) => c.code == (_libraryService.lastCountryCode ?? countryCode),
    );
    _language ??= Languages.defaultLanguages.firstWhereOrNull(
      (c) => c.isoCode == _libraryService.lastLanguageCode,
    );

    if (_connectedHost?.isNotEmpty == true) {
      _tag ??= lastFav == null || tags == null || tags!.isEmpty
          ? null
          : tags!.firstWhere((t) => t.name.contains(lastFav));
    }

    setSearchQuery(search: RadioSearch.values[index]);

    return _connectedHost;
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery({RadioSearch? search, String? query}) {
    switch (search) {
      case RadioSearch.country:
        _searchQuery = country?.name;
        break;
      case RadioSearch.tag:
        _searchQuery = tag?.name;
      case RadioSearch.language:
        _searchQuery = language?.name.toLowerCase();
      default:
        _searchQuery = query ?? _searchQuery;
    }
    notifyListeners();
  }

  RadioCollectionView _radioCollectionView = RadioCollectionView.stations;
  RadioCollectionView get radioCollectionView => _radioCollectionView;
  void setRadioCollectionView(RadioCollectionView value) {
    if (value == _radioCollectionView) return;
    _radioCollectionView = value;
    notifyListeners();
  }
}

enum RadioCollectionView {
  stations,
  tags,
  history;

  String localize(AppLocalizations l10n) {
    return switch (this) {
      stations => l10n.stations,
      tags => l10n.tags,
      history => l10n.history,
    };
  }
}
