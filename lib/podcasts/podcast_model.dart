import 'dart:async';

import 'package:collection/collection.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/podcast_genre.dart';
import '../common/view/languages.dart';
import '../library/library_service.dart';
import 'podcast_service.dart';

class PodcastModel extends SafeChangeNotifier {
  PodcastModel({
    required PodcastService podcastService,
    required LibraryService libraryService,
  })  : _podcastService = podcastService,
        _libraryService = libraryService;

  final PodcastService _podcastService;
  final LibraryService _libraryService;

  StreamSubscription<bool>? _searchChangedSub;

  SearchResult? get searchResult => _podcastService.searchResult;

  bool? _searchActive;
  bool? get searchActive => _searchActive;
  void setSearchActive(bool value) {
    if (value == _searchActive) return;
    _searchActive = value;
    notifyListeners();
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery(String? value) {
    if (value == null || value == _searchQuery) return;
    _searchQuery = value;
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

  List<Country> get sortedCountries {
    if (_country == null) return Country.values;
    final notSelected =
        Country.values.where((c) => c != _country).toList().sorted(
              (a, b) => a.name.compareTo(b.name),
            );
    final list = <Country>[_country!, ...notSelected];

    return list;
  }

  int _limit = 20;
  int get limit => _limit;
  void setLimit(int? value) {
    if (value == null || value == _limit) return;
    _limit = value;
    notifyListeners();
  }

  String? _selectedFeedUrl;
  String? get selectedFeedUrl => _selectedFeedUrl;
  void setSelectedFeedUrl(String? value) {
    if (value == _selectedFeedUrl) return;
    _selectedFeedUrl = value;
    notifyListeners();
  }

  var _firstUpdateChecked = false;
  Future<void> init({
    String? countryCode,
    required String updateMessage,
    bool forceInit = false,
  }) async {
    await _podcastService.init(forceInit: forceInit);

    _searchActive ??= _libraryService.podcasts.isEmpty;

    _country ??= Country.values.firstWhereOrNull(
      (c) => c.code == (_libraryService.lastCountryCode ?? countryCode),
    );

    _language ??= Languages.defaultLanguages.firstWhereOrNull(
      (c) => c.isoCode == _libraryService.lastLanguageCode,
    );

    _searchChangedSub ??= _podcastService.searchChanged.listen((_) {
      notifyListeners();
    });

    if (forceInit ||
        _podcastService.searchResult == null ||
        _podcastService.searchResult?.items.isEmpty == true) {
      search();
    }

    if (_firstUpdateChecked == false) {
      update(updateMessage);
    }
    _firstUpdateChecked = true;

    notifyListeners();
  }

  void update(String updateMessage) {
    _setCheckingForUpdates(true);
    _podcastService
        .updatePodcasts(
          oldPodcasts: _libraryService.podcasts,
          updatePodcast: _libraryService.updatePodcast,
          updateMessage: updateMessage,
        )
        .then((_) => _setCheckingForUpdates(false));
  }

  bool _checkingForUpdates = false;
  bool get checkingForUpdates => _checkingForUpdates;
  void _setCheckingForUpdates(bool value) {
    if (_checkingForUpdates == value) return;
    _checkingForUpdates = value;
    notifyListeners();
  }

  bool _updatesOnly = false;
  bool get updatesOnly => _updatesOnly;
  void setUpdatesOnly(bool value) {
    if (_updatesOnly == value) return;
    _updatesOnly = value;
    notifyListeners();
  }

  bool _downloadsOnly = false;
  bool get downloadsOnly => _downloadsOnly;
  void setDownloadsOnly(bool value) {
    if (_downloadsOnly == value) return;
    _downloadsOnly = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchChangedSub?.cancel();
    super.dispose();
  }

  Future<SearchResult?> search({
    String? searchQuery,
  }) async {
    return _podcastService.search(
      searchQuery: searchQuery,
      country: _podcastService.searchWithPodcastIndex ? null : _country,
      podcastGenre: podcastGenre,
      limit: limit,
      language: _podcastService.searchWithPodcastIndex ? _language : null,
    );
  }
}
