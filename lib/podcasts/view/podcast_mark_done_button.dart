import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../podcast_model.dart';

class PodcastMarkDoneButton extends StatelessWidget with WatchItMixin {
  const PodcastMarkDoneButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final podcast = watchPropertyValue(
      (PodcastModel m) => m.getPodcastEpisodesFromCache(feedUrl),
    );

    return IconButton(
      tooltip: context.l10n.markAllEpisodesAsDone,
      onPressed: podcast == null
          ? null
          : () {
              di<PlayerModel>().safeAllLastPositions(podcast);
              di<LibraryModel>().removePodcastUpdate(feedUrl);
            },
      icon: Icon(Iconz.markAllRead),
    );
  }
}

class EpisodeMarkDownButton extends StatelessWidget with WatchItMixin {
  const EpisodeMarkDownButton({super.key, required this.episode});

  final Audio episode;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.markEpisodeAsDone,
      onPressed: episode.website == null
          ? null
          : () => showFutureLoadingDialog(
              context: context,
              future: () async {
                await di<PlayerModel>().safeAllLastPositions([episode]);
                await di<LibraryModel>().removePodcastUpdate(episode.website!);
              },
            ),
      icon: Icon(Iconz.markAllRead),
    );
  }
}
