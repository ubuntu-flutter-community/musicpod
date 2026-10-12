import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/audio_filter.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../manager/episodes_manager.dart';
import '../manager/subscribed_podcasts_manager.dart';

class PodcastReorderButton extends ConsumerWidget {
  const PodcastReorderButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesState = ref.watch(episodesManagerProvider(feedUrl)).value;
    final ascending = episodesState?.order == AudioSortOrder.ascending;

    final podcastSubscribed =
        ref.watch(subscribedPodcastsManagerProvider).value?.contains(feedUrl) ??
        false;

    return IconButton(
      tooltip: context.l10n.reorder,
      onPressed: podcastSubscribed
          ? () => ref
                .read(episodesManagerProvider(feedUrl).notifier)
                .reorder(
                  ascending
                      ? AudioSortOrder.descending
                      : AudioSortOrder.ascending,
                )
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
