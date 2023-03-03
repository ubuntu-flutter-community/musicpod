import 'package:collection/collection.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:music/data/audio.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PodcastModel extends SafeChangeNotifier {
  PodcastModel() : _search = Search();

  final Search _search;

  List<Audio>? _searchResult;
  List<Audio>? get searchResult => _searchResult;
  set searchResult(List<Audio>? podcasts) {
    _searchResult = podcasts;
    notifyListeners();
  }

  Set<Audio>? _charts;
  Set<Audio>? get charts => _charts;
  set charts(Set<Audio>? audios) {
    _charts = audios;
    notifyListeners();
  }

  Country _country = Country.GERMANY;
  Country get country => _country;
  set country(Country value) {
    if (value == _country) return;
    _country = value;
    notifyListeners();
  }

  Future<void> loadCharts() async {
    charts = null;
    final chartsSearch = await _search.charts(
      genre: 'Science',
      limit: 20,
      country: _country,
    );

    if (chartsSearch.successful && chartsSearch.items.isNotEmpty) {
      _charts ??= {};
      _charts?.clear();

      for (var item in chartsSearch.items) {
        if (item.feedUrl != null) {
          final Podcast podcast = await Podcast.loadFeed(
            url: item.feedUrl!,
          );

          _charts?.add(
            Audio(
              url: podcast.episodes?.firstOrNull?.contentUrl,
              audioType: AudioType.podcast,
              name: podcast.title,
              imageUrl: podcast.image,
              metadata: Metadata(
                title: podcast.title,
                album: podcast.title,
                artist: podcast.title,
              ),
              description: podcast.description,
            ),
          );
        }
      }
    } else {
      _charts = null;
    }

    notifyListeners();
  }

  Future<void> search({String? searchQuery}) async {
    searchResult = null;
    if (searchQuery?.isNotEmpty == true) {
      final podcastSearch = <Audio>[];

      SearchResult results = await _search.search(
        searchQuery!,
        country: Country.GERMANY,
        limit: 10,
      );

      if (results.items.firstOrNull?.feedUrl != null) {
        final Podcast podcast = await Podcast.loadFeed(
          url: results.items.firstOrNull!.feedUrl!,
        );

        if (podcast.episodes?.isNotEmpty == true) {
          for (var e in podcast.episodes!) {
            if (e.contentUrl != null) {
              podcastSearch.add(
                Audio(
                  url: e.contentUrl,
                  audioType: AudioType.podcast,
                  name: '${podcast.title ?? ''} - ${e.title}',
                  imageUrl: e.imageUrl,
                  metadata: Metadata(
                    title: e.title,
                    album: podcast.title,
                    artist: podcast.title,
                  ),
                  description: podcast.description,
                ),
              );
            }
          }
        }
      }
      searchResult = podcastSearch;
    }
  }
}
