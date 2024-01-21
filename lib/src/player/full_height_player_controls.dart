import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import 'play_button.dart';
import 'playback_rate_button.dart';
import 'repeat_button.dart';
import 'shuffle_button.dart';

class FullHeightPlayerControls extends StatelessWidget {
  const FullHeightPlayerControls({
    super.key,
    required this.playPrevious,
    required this.playNext,
    required this.active,
    required this.showPlaybackRate,
  });

  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;
  final bool active;
  final bool showPlaybackRate;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    const spacing = 7.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        if (showPlaybackRate)
          PlaybackRateButton(active: active)
        else
          ShuffleButton(active: active),
        IconButton(
          onPressed: !active ? null : () => playPrevious(),
          icon: Icon(Iconz().skipBackward),
        ),
        CircleAvatar(
          radius: avatarIconSize,
          backgroundColor: theme.colorScheme.inverseSurface,
          child: PlayButton(
            iconColor: theme.colorScheme.onInverseSurface,
            active: active,
          ),
        ),
        IconButton(
          onPressed: !active ? null : () => playNext(),
          icon: Icon(Iconz().skipForward),
        ),
        RepeatButton(active: active),
      ],
    );
  }
}
