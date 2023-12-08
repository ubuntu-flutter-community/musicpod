import 'dart:async';

import 'package:collection/collection.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../library.dart';
import '../../podcasts.dart';
import '../data/podcast_genre.dart';

class PodcastModel extends SafeChangeNotifier {
  PodcastModel(
    this._podcastService,
    this._libraryService,
  );

  final PodcastService _podcastService;
  final LibraryService _libraryService;

  StreamSubscription<bool>? _searchChangedSub;

  SearchResult? get searchResult => _podcastService.searchResult;

  bool _searchActive = false;
  bool get searchActive => _searchActive;
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

  Language _language = Language.none;
  Language get language => _language;
  set language(Language value) {
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
    required bool isOnline,
  }) async {
    final c = Country.values.firstWhereOrNull((c) => c.code == countryCode);
    if (c != null) {
      _country = c;
    }

    _searchChangedSub = _podcastService.searchChanged.listen((_) {
      notifyListeners();
    });

    if (!isOnline) return;

    if (_podcastService.searchResult == null ||
        _podcastService.searchResult?.items.isEmpty == true) {
      search();
    }

    if (_firstUpdateChecked == false) {
      update(updateMessage);
    }
    _firstUpdateChecked = true;
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

  void search({
    String? searchQuery,
  }) {
    _podcastService.search(
      searchQuery: searchQuery,
      country: _country,
      podcastGenre: podcastGenre,
      limit: limit,
    );
  }
}
