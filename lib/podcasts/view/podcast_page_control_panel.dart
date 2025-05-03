import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../common/data/audio.dart';
import '../../common/view/audio_tile_option_button.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
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
  });

  final String feedUrl;
  final String title;
  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final width = context.mediaQuerySize.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: space(
        children: [
          if (width > 700) PodcastReplayButton(feedUrl: feedUrl),
          PodcastMarkDoneButton(feedUrl: feedUrl),
          PodcastSubButton(
            audios: audios,
            pageId: feedUrl,
          ),
          AvatarPlayButton(
            audios: audios,
            pageId: feedUrl,
          ),
          PodcastPageSearchButton(feedUrl: feedUrl),
          PodcastReorderButton(feedUrl: feedUrl),
          if (width > 700)
            AudioTileOptionButton(
              audios: audios,
              playlistId: feedUrl,
              allowRemove: false,
              selected: false,
              searchTerm: title,
              title: Text(title),
              subTitle: Text(
                audios.firstOrNull?.artist ?? '',
              ),
            ),
        ],
      ),
    );
  }
}
