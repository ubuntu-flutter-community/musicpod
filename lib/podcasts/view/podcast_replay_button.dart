import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../podcast_model.dart';

class PodcastReplayButton extends StatelessWidget with WatchItMixin {
  const PodcastReplayButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final podcast = watchPropertyValue(
      (PodcastModel m) => m.getPodcastEpisodesFromCache(feedUrl),
    );
    return IconButton(
      tooltip: context.l10n.replayAllEpisodes,
      onPressed: podcast == null
          ? null
          : () => di<PlayerModel>().removeLastPositions(podcast),
      icon: Icon(Iconz.replay),
    );
  }
}
