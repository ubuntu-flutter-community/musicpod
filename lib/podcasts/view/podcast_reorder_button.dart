import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../podcast_manager.dart';

class PodcastReorderButton extends StatelessWidget with WatchItMixin {
  const PodcastReorderButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final ascending = watchValue(
      (PodcastManager m) =>
          m.reorderPodcastCommand.select((v) => v.contains(feedUrl)),
    );

    final podcastSubscribed = watchValue(
      (PodcastManager m) =>
          m.togglePodcastCommand.select((v) => v.contains(feedUrl)),
    );

    return IconButton(
      tooltip: context.l10n.reorder,
      onPressed: podcastSubscribed
          ? () => di<PodcastManager>().reorderPodcastCommand.run((
              feedUrl: feedUrl,
              ascending: !ascending,
            ))
          : null,
      icon: Iconz.ascending == Iconz.materialAscending && ascending
          ? Transform.flip(
              flipX: true,
              child: Transform.rotate(
                angle: pi,
                child: Icon(Iconz.materialAscending),
              ),
            )
          : Icon(ascending ? Iconz.ascending : Iconz.descending),
    );
  }
}
