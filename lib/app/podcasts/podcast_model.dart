import 'dart:async';

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:musicpod/data/podcast_genre.dart';
import 'package:musicpod/service/library_service.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PodcastModel extends SafeChangeNotifier {
  PodcastModel(
    this._podcastService,
    this._libraryService,
    this._connectivity,
    this._notificationsClient,
  );

  final PodcastService _podcastService;
  final LibraryService _libraryService;
  final Connectivity _connectivity;
  final NotificationsClient _notificationsClient;

  StreamSubscription<bool>? _chartsChangedSub;
  StreamSubscription<bool>? _searchChangedSub;

  List<Item>? get charts => _podcastService.chartsPodcasts;
  List<Item>? get podcastSearchResult => _podcastService.searchResult;

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

  Future<void> init({
    String? countryCode,
    required String updateMessage,
  }) async {
    _chartsChangedSub = _podcastService.chartsChanged.listen((_) {
      notifyListeners();
    });
    _searchChangedSub = _podcastService.searchChanged.listen((_) {
      notifyListeners();
    });
    if (_podcastService.chartsPodcasts?.isNotEmpty == true) return;
    final c = Country.values.firstWhereOrNull((c) => c.code == countryCode);
    if (c != null) {
      _country = c;
    }
    if (_podcastService.chartsPodcasts == null ||
        _podcastService.chartsPodcasts?.isEmpty == true) {
      loadCharts();
    }

    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) return;
    _podcastService.updatePodcasts(
      oldPodcasts: _libraryService.podcasts,
      updatePodcast: _libraryService.updatePodcast,
      notify: _notificationsClient.notify,
      updateMessage: updateMessage,
    );
  }

  @override
  void dispose() {
    _chartsChangedSub?.cancel();
    _searchChangedSub?.cancel();
    super.dispose();
  }

  void loadCharts() =>
      _podcastService.loadCharts(podcastGenre: podcastGenre, country: country);

  void search({
    String? searchQuery,
  }) {
    _podcastService.search(
      language: _language,
      searchQuery: searchQuery,
      country: _country,
    );
  }
}
