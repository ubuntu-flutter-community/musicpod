import 'dart:math';

import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class PodcastReorderButton extends StatelessWidget with WatchItMixin {
  const PodcastReorderButton({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final ascending =
        watchPropertyValue((LibraryModel m) => m.showPodcastAscending(feedUrl));

    return IconButton(
      tooltip: context.l10n.reorder,
      onPressed: () => di<LibraryModel>()
          .reorderPodcast(feedUrl: feedUrl, ascending: !ascending),
      icon: Iconz.ascending == Iconz.materialAscending && ascending
          ? Transform.flip(
              flipX: true,
              child: Transform.rotate(
                angle: pi,
                child: Icon(
                  Iconz.materialAscending,
                ),
              ),
            )
          : Icon(ascending ? Iconz.ascending : Iconz.descending),
    );
  }
}
