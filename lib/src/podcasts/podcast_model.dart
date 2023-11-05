import 'dart:async';

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../library.dart';
import '../../podcasts.dart';
import '../data/podcast_genre.dart';

class PodcastModel extends SafeChangeNotifier {
  PodcastModel(
    this._podcastService,
    this._libraryService,
    this._connectivity, [
    this._notificationsClient,
  ]);

  final PodcastService _podcastService;
  final LibraryService _libraryService;
  final Connectivity _connectivity;
  final NotificationsClient? _notificationsClient;

  StreamSubscription<bool>? _searchChangedSub;

  SearchResult? get searchResult => _podcastService.searchResult;

  StreamSubscription<ConnectivityResult>? _conSub;

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

  Future<void> init({
    String? countryCode,
    required String updateMessage,
  }) async {
    final c = Country.values.firstWhereOrNull((c) => c.code == countryCode);
    if (c != null) {
      _country = c;
    }

    _searchChangedSub = _podcastService.searchChanged.listen((_) {
      notifyListeners();
    });

    _conSub = _connectivity.onConnectivityChanged.listen((result) {
      if (_conResult == ConnectivityResult.none &&
          result != ConnectivityResult.none) {
        // update(updateMessage);
      }
      _conResult = result;
    });

    final res = await _connectivity.checkConnectivity();
    if (res == ConnectivityResult.none) return;

    if (_podcastService.searchResult == null ||
        _podcastService.searchResult?.items.isEmpty == true) {
      search();
    }

    update(updateMessage);
  }

  void update(String updateMessage) {
    if (_conResult == ConnectivityResult.none) return;
    _setCheckingForUpdates(true);
    _podcastService
        .updatePodcasts(
          oldPodcasts: _libraryService.podcasts,
          updatePodcast: _libraryService.updatePodcast,
          notify: _notificationsClient?.notify,
          updateMessage: updateMessage,
        )
        .then((_) => _setCheckingForUpdates(false));
  }

  ConnectivityResult? _conResult;
  bool _checkingForUpdates = false;
  bool get checkingForUpdates => _checkingForUpdates;
  void _setCheckingForUpdates(bool value) {
    if (_checkingForUpdates == value) return;
    _checkingForUpdates = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchChangedSub?.cancel();
    _conSub?.cancel();
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
