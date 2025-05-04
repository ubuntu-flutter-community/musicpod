import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';

class PodcastTileProgress extends StatelessWidget with WatchItMixin {
  const PodcastTileProgress({
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
    final theme = context.theme;

    final pos = (selected
            ? watchPropertyValue((PlayerModel m) => m.position)
            : lastPosition) ??
        const Duration(seconds: 0);

    final dur = (selected
            ? watchPropertyValue((PlayerModel m) => m.duration)
            : duration) ??
        const Duration(seconds: 1);

    final sliderActive = dur.inSeconds > 0 && dur.inSeconds >= pos.inSeconds;

    return RepaintBoundary(
      child: Progress(
        padding: EdgeInsets.zero,
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.9)
            : theme.colorScheme.primary.withValues(alpha: 0.4),
        value: sliderActive
            ? (pos.inSeconds.toDouble() / dur.inSeconds.toDouble())
            : 0,
        backgroundColor: Colors.transparent,
        strokeWidth: progressStrokeWidth,
      ),
    );
  }
}
