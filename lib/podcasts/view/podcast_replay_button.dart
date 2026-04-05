import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../podcast_manager.dart';

class PodcastReplayButton extends StatelessWidget with WatchItMixin {
  const PodcastReplayButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final podcast = watchValue(
      (PodcastManager m) => m.getEpisodesCommand(feedUrl),
    );
    return IconButton(
      tooltip: context.l10n.replayAllEpisodes,
      onPressed: () => di<PlayerModel>().removeLastPositions(podcast),
      icon: Icon(Iconz.replay),
    );
  }
}
