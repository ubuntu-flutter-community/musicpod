import 'package:podcast_search/podcast_search.dart';

import '../common/data/audio.dart';

extension PodcastX on Podcast {
  List<Audio> getAudios({
    String? itemImgUrl,
    String? genre,
  }) =>
      episodes
          .where((e) => e.contentUrl != null)
          .map(
            (e) => Audio.fromPodcast(
              episode: e,
              podcast: this,
              itemImageUrl: itemImgUrl,
              genre: genre,
            ),
          )
          .toList();
}
