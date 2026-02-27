import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../common/data/audio.dart';
import '../../common/view/audio_tile_option_button.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/theme.dart';
import 'podcast_mark_done_button.dart';
import 'podcast_page_search_button.dart';
import 'podcast_reorder_button.dart';
import 'podcast_replay_button.dart';
import 'podcast_sub_button.dart';

class PodcastPageControlPanel extends StatelessWidget {
  const PodcastPageControlPanel({
    super.key,
    required this.feedUrl,
    required this.audios,
    required this.title,
    this.imageUrl,
  });

  final String feedUrl;
  final String title;
  final String? imageUrl;
  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final artist = audios.firstOrNull?.artist ?? '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: space(
        children: [
          PodcastReplayButton(feedUrl: feedUrl),
          PodcastMarkDoneButton(feedUrl: feedUrl),
          PodcastSubButton(
            pageId: feedUrl,
            imageUrl: imageUrl,
            name: title,
            artist: artist,
          ),
          AvatarPlayButton(audios: audios, pageId: feedUrl),
          PodcastPageSearchButton(feedUrl: feedUrl),
          PodcastReorderButton(feedUrl: feedUrl),
          AudioTileOptionButton(
            audios: audios,
            playlistId: feedUrl,
            allowRemove: false,
            searchTerm: title,
            title: Text(title),
            subTitle: Text(artist),
          ),
        ],
      ),
    );
  }
}
