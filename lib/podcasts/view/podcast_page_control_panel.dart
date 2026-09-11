import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/audio_page_type.dart';
import '../../common/view/audio_tile_option_button.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/confirm.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/player_manager.dart';
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

  void _onPlayAllPressed(BuildContext context) {
    final playerManager = di<PlayerManager>();
    final pageIsQueue = playerManager.queue.name == feedUrl;

    if (pageIsQueue) {
      playerManager.playOrPause();
      return;
    }

    final episodesManager = di<EpisodesManager>(param1: feedUrl);
    final allEpisodes = episodesManager.allFilteredEpisodes;
    final loadedEpisodes = episodesManager.command.value?.episodes ?? [];

    if (allEpisodes.isEmpty) return;

    if (!episodesManager.hasMore ||
        loadedEpisodes.length >= allEpisodes.length) {
      playerManager.play(audios: allEpisodes, listName: feedUrl);
      return;
    }

    ConfirmationDialog.show(
      context: context,
      title: Text(context.l10n.playAll),
      content: Text(
        'Play only the ${loadedEpisodes.length} loaded episodes or all ${allEpisodes.length} episodes?',
      ),
      confirmLabel: '${context.l10n.playAll} (${allEpisodes.length})',
      cancelLabel: '${context.l10n.play} (${loadedEpisodes.length})',
      onConfirm: () =>
          playerManager.play(audios: allEpisodes, listName: feedUrl),
      onCancel: () =>
          playerManager.play(audios: loadedEpisodes, listName: feedUrl),
    );
  }

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
            onPressed: () => _onPlayAllPressed(context),
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
