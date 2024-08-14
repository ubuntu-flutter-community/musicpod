import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';

class AudioProgress extends StatelessWidget with WatchItMixin {
  const AudioProgress({
    super.key,
    this.lastPosition,
    this.duration,
    required this.selected,
  });

  final Duration? lastPosition;
  final Duration? duration;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    final pos = (selected
            ? watchPropertyValue((PlayerModel m) => m.position)
            : lastPosition) ??
        const Duration(seconds: 0);

    final dur = (selected
            ? watchPropertyValue((PlayerModel m) => m.duration)
            : duration) ??
        const Duration(seconds: 1);

    bool sliderActive = dur.inSeconds > 0 && dur.inSeconds >= pos.inSeconds;

    return RepaintBoundary(
      child: SizedBox(
        height: podcastProgressSize,
        width: podcastProgressSize,
        child: Progress(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.9)
              : theme.colorScheme.primary.withOpacity(0.4),
          value: sliderActive
              ? (pos.inSeconds.toDouble() / dur.inSeconds.toDouble())
              : 0,
          backgroundColor: Colors.transparent,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
