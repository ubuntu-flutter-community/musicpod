import 'dart:async';

import 'package:collection/collection.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/data/countries.dart';
import 'package:musicpod/data/podcast_genre.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PodcastModel extends SafeChangeNotifier {
  final PodcastService _service;
  PodcastModel(this._service) : _search = Search();
  StreamSubscription<bool>? _chartsChangedSub;

  final Search _search;

  Set<Set<Audio>>? _podcastSearchResult;
  Set<Set<Audio>>? get podcastSearchResult => _podcastSearchResult;
  set podcastSearchResult(Set<Set<Audio>>? value) {
    _podcastSearchResult = value;
    notifyListeners();
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery(String? value) {
    if (value == null || value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  Set<Set<Audio>>? get chartsPodcasts => _service.chartsPodcasts;

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

  PodcastGenre _podcastGenre = PodcastGenre.science;
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
    super.dispose();
  }

  void loadCharts() =>
      _service.loadCharts(podcastGenre: podcastGenre, country: country);

  Future<void> search({String? searchQuery, bool useAlbumImage = false}) async {
    if (searchQuery?.isEmpty == true) return;
    podcastSearchResult = null;

    SearchResult results = await _search.search(
      searchQuery!,
      country: _country,
      language: _language,
      limit: 10,
    );

    if (results.successful && results.items.isNotEmpty) {
      _podcastSearchResult ??= {};
      _podcastSearchResult?.clear();

      for (var item in results.items) {
        if (item.feedUrl != null) {
          try {
            final Podcast podcast = await Podcast.loadFeed(
              url: item.feedUrl!,
            );

            if (podcast.episodes?.isNotEmpty == true) {
              final episodes = <Audio>{};

              for (var episode in podcast.episodes!) {
                if (episode.contentUrl != null) {
                  final audio = Audio(
                    url: episode.contentUrl,
                    audioType: AudioType.podcast,
                    name: '${podcast.title ?? ''} - ${episode.title}',
                    imageUrl: useAlbumImage
                        ? podcast.image ?? episode.imageUrl
                        : episode.imageUrl ?? podcast.image,
                    metadata: Metadata(
                      title: episode.title,
                      album: podcast.title,
                      artist: podcast.copyright,
                    ),
                    description: podcast.description,
                    website: podcast.url,
                  );

                  episodes.add(audio);
                }
              }
              _podcastSearchResult?.add(episodes);
              notifyListeners();
            }
          } on PodcastFailedException {
            notifyListeners();
          }
        }
      }
    } else {
      podcastSearchResult = {};
    }
  }
}
