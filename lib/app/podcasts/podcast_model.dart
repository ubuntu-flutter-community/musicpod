import 'package:metadata_god/metadata_god.dart';
import 'package:music/data/audio.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PodcastModel extends SafeChangeNotifier {
  final Set<Audio> _podcasts = {};
  Set<Audio> get podcasts => _podcasts;

  Future<void> init() async {
    var search = Search();

    SearchResult results = await search.search(
      'Late Night Linux',
      country: Country.UNITED_KINGDOM,
      limit: 10,
    );

    if (results.items[0].feedUrl != null) {
      Podcast podcast = await Podcast.loadFeed(url: results.items[0].feedUrl!);

      for (var e in podcast.episodes ?? <Episode>[]) {
        if (e.contentUrl != null) {
          _podcasts.add(
            Audio(
              url: e.contentUrl,
              audioType: AudioType.podcast,
              name: '${podcast.title ?? ''} - ${e.title}',
              imageUrl: e.imageUrl,
              metadata: Metadata(
                title: e.title,
                album: podcast.description,
                artist: podcast.title,
              ),
            ),
          );
        }
      }
    }
    notifyListeners();
  }
}
