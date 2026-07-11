import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/audio_page_type.dart';
import '../../common/view/audio_tile_option_button.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/theme.dart';
import '../manager/episodes_manager.dart';
import '../manager/podcast_short_info_manager.dart';
import 'podcast_mark_done_button.dart';
import 'podcast_page_search_button.dart';
import 'podcast_reorder_button.dart';
import 'podcast_replay_button.dart';
import 'podcast_sub_button.dart';

class PodcastPageControlPanel extends StatelessWidget with WatchItMixin {
  const PodcastPageControlPanel({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final shortInfo = watchValue(
      (PodcastShortInfoManager m) => m.command,
      param1: feedUrl,
    );

    final artist = shortInfo?.artist ?? '';
    final title = shortInfo?.name ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: space(
        children: [
          PodcastReplayButton(feedUrl: feedUrl),
          PodcastMarkDoneButton(feedUrl: feedUrl),
          PodcastSubButton(
            pageId: feedUrl,
            imageUrl: shortInfo?.imageUrl,
            name: title,
            artist: artist,
          ),
          AvatarPlayButton(
            pageId: feedUrl,
            audioPageType: AudioPageType.podcast,
          ),
          PodcastPageSearchButton(feedUrl: feedUrl),
          PodcastReorderButton(feedUrl: feedUrl),
          PodcastPageOptionButton(
            feedUrl: feedUrl,
            title: title,
            artist: artist,
          ),
        ],
      ),
    );
  }
}

class PodcastPageOptionButton extends StatelessWidget with WatchItMixin {
  const PodcastPageOptionButton({
    super.key,
    required this.feedUrl,
    this.title,
    this.artist,
  });

  final String feedUrl;
  final String? title;
  final String? artist;

  @override
  Widget build(BuildContext context) {
    final episodeResults = watchValue(
      (EpisodesManager m) => m.command.results,
      param1: feedUrl,
    );
    return AudioTileOptionButton(
      enabled: !episodeResults.isRunning && !episodeResults.hasError,
      audios: episodeResults.data?.episodes ?? [],
      playlistId: feedUrl,
      allowRemove: false,
      searchTerm: title ?? '',
      title: Text(title ?? ''),
      subTitle: Text(artist ?? ''),
    );
  }
}
