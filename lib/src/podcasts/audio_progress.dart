import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../../build_context_x.dart';
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
    final theme = context.t;

    final service = getService<PlayerService>();

    final pos = (selected ? service.position.watch(context) : lastPosition) ??
        Duration.zero;

    final dur = (selected ? service.duration.watch(context) : duration) ??
        Duration.zero;

    bool sliderActive = dur.inSeconds > pos.inSeconds;

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
