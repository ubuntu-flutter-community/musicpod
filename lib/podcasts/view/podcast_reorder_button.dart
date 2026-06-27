import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/audio_filter.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../manager/episodes_manager.dart';
import '../manager/subscribed_podcasts_manager.dart';

class PodcastReorderButton extends StatelessWidget with WatchItMixin {
  const PodcastReorderButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final ascending = watchValue(
      (EpisodesManager m) =>
          m.command.select((v) => v?.order == AudioSortOrder.ascending),
      param1: feedUrl,
    );

    final podcastSubscribed = watchValue(
      (SubscribedPodcastsManager m) =>
          m.command.select((v) => v.contains(feedUrl)),
    );

    return IconButton(
      tooltip: context.l10n.reorder,
      onPressed: podcastSubscribed
          ? () => di<EpisodesManager>(param1: feedUrl).command.run((
              order: ascending
                  ? AudioSortOrder.descending
                  : AudioSortOrder.ascending,
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
