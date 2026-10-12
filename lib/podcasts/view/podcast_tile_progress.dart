import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/duration_manager.dart';
import '../../player/manager/position_manager.dart';

class PodcastTileProgress extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    final pos =
        (selected
            ? ref.watch(positionManagerProvider)
            : lastPosition) ??
        const Duration(seconds: 0);

    final dur =
        (selected
            ? ref.watch(durationManagerProvider)
            : duration) ??
        const Duration(seconds: 1);

    final sliderActive = dur.inSeconds > 0 && dur.inSeconds >= pos.inSeconds;

    return RepaintBoundary(
      child: Progress(
        adaptive: false,
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

