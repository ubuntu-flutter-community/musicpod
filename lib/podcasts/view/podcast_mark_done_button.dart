import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';

class PodcastMarkDoneButton extends StatelessWidget with WatchItMixin {
  const PodcastMarkDoneButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final podcast = watchPropertyValue(
      (LibraryModel m) => m.getPodcast(feedUrl),
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
