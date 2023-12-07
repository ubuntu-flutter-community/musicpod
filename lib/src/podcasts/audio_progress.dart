import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../player.dart';

class AudioProgress extends StatelessWidget {
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
    final theme = Theme.of(context);

    final pos = (selected
            ? context.select((PlayerModel m) => m.position)
            : lastPosition) ??
        Duration.zero;

    bool sliderActive = duration != null && duration!.inSeconds > pos.inSeconds;

    return RepaintBoundary(
      child: SizedBox(
        height: podcastProgressSize,
        width: podcastProgressSize,
        child: Progress(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.9)
              : theme.colorScheme.primary.withOpacity(0.4),
          value: sliderActive
              ? (pos.inSeconds.toDouble() / duration!.inSeconds.toDouble())
              : 0,
          backgroundColor: Colors.transparent,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
