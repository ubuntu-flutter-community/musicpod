import 'dart:async';

import 'package:collection/collection.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/data/countries.dart';
import 'package:musicpod/data/podcast_genre.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PodcastModel extends SafeChangeNotifier {
  PodcastModel(this._service);

  final PodcastService _service;

  StreamSubscription<bool>? _chartsChangedSub;
  StreamSubscription<bool>? _searchChangedSub;

  Set<Set<Audio>>? get chartsPodcasts => _service.chartsPodcasts;
  Set<Set<Audio>>? get podcastSearchResult => _service.searchResult;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery(String? value) {
    if (value == null || value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  Country _country = Country.UNITED_STATES;
  Country get country => _country;
  set country(Country value) {
    if (value == _country) return;
    _country = value;
    notifyListeners();
  }

  Language _language = Language.NONE;
  Language get language => _language;
  set language(Language value) {
    if (value == _language) return;
    _language = value;
    notifyListeners();
  }

  PodcastGenre _podcastGenre = PodcastGenre.all;
  PodcastGenre get podcastGenre => _podcastGenre;
  set podcastGenre(PodcastGenre value) {
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
    final notSelected = countries.where((c) => c != country).toList().sorted(
          (a, b) => codeToCountry[a.countryCode] == null ||
                  codeToCountry[b.countryCode] == null
              ? 0
              : codeToCountry[a.countryCode]!
                  .compareTo(codeToCountry[b.countryCode]!),
        );
    final list = <Country>[country, ...notSelected];

    return list;
  }

  void init(String? countryCode) {
    _chartsChangedSub = _service.chartsChanged.listen((_) {
      notifyListeners();
    });
    _searchChangedSub = _service.searchChanged.listen((_) {
      notifyListeners();
    });
    if (_service.chartsPodcasts?.isNotEmpty == true) return;
    final c = countries.firstWhereOrNull((c) => c.countryCode == countryCode);
    if (c != null) {
      _country = c;
    }
    loadCharts();
  }

  @override
  void dispose() {
    _chartsChangedSub?.cancel();
    _searchChangedSub?.cancel();
    super.dispose();
  }

  void loadCharts() =>
      _service.loadCharts(podcastGenre: podcastGenre, country: country);

  void search({
    String? searchQuery,
    bool useAlbumImage = false,
  }) {
    _service
        .search(
          language: _language,
          searchQuery: searchQuery,
          country: _country,
          useAlbumImage: useAlbumImage,
        )
        .then((_) => notifyListeners());
  }

  Future<Set<Audio>> findEpisodes({required String url}) async =>
      await _service.findEpisodes(url: url);
}
