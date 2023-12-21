import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../data.dart';
import 'play_button.dart';
import 'repeat_button.dart';
import 'shuffle_button.dart';

class FullHeightPlayerControls extends StatelessWidget {
  const FullHeightPlayerControls({
    super.key,
    this.audio,
    required this.playPrevious,
    required this.playNext,
    required this.active,
  });

  final Audio? audio;
  final Future<void> Function({bool doubleTap}) playPrevious;
  final Future<void> Function() playNext;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    const spacing = 7.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        ShuffleButton(active: active),
        GestureDetector(
          onDoubleTap: !active ? null : () => playPrevious(doubleTap: true),
          child: IconButton(
            onPressed: !active ? null : () => playPrevious(),
            icon: Icon(Iconz().skipBackward),
          ),
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
