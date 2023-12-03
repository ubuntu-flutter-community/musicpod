import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data.dart';
import '../../theme.dart';

class FullHeightPlayerControls extends StatelessWidget {
  const FullHeightPlayerControls({
    super.key,
    this.audio,
    required this.setRepeatSingle,
    required this.repeatSingle,
    required this.shuffle,
    required this.setShuffle,
    required this.isPlaying,
    required this.playPrevious,
    required this.playNext,
    required this.pause,
    required this.playOrPause,
    required this.queue,
    required this.isOnline,
  });

  final Audio? audio;
  final List<Audio> queue;
  final bool repeatSingle;
  final void Function(bool) setRepeatSingle;
  final bool shuffle;
  final void Function(bool) setShuffle;
  final bool isPlaying;
  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;
  final Future<void> Function() pause;
  final Future<void> Function() playOrPause;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final active = audio?.path != null || isOnline;

    const spacing = 7.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        IconButton(
          icon: Icon(
            Iconz().shuffle,
            color: !active
                ? theme.disabledColor
                : (shuffle
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface),
          ),
          onPressed: !active ? null : () => setShuffle(!(shuffle)),
        ),
        IconButton(
          onPressed: !active ? null : () => playPrevious(),
          icon: Icon(Iconz().skipBackward),
        ),
        CircleAvatar(
          backgroundColor: theme.colorScheme.inverseSurface,
          child: IconButton(
            color: theme.colorScheme.onInverseSurface,
            onPressed: !active || audio == null
                ? null
                : () {
                    if (isPlaying) {
                      pause();
                    } else {
                      playOrPause();
                    }
                  },
            icon: isPlaying
                ? Icon(
                    Iconz().pause,
                  )
                : Padding(
                    padding: appleStyled
                        ? const EdgeInsets.only(left: 3)
                        : EdgeInsets.zero,
                    child: Icon(Iconz().playFilled),
                  ),
          ),
        ),
        IconButton(
          onPressed: !active ? null : () => playNext(),
          icon: Icon(Iconz().skipForward),
        ),
        IconButton(
          icon: Icon(
            Iconz().repeatSingle,
            color: !active
                ? theme.disabledColor
                : (repeatSingle
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface),
          ),
          onPressed: !active ? null : () => setRepeatSingle(!(repeatSingle)),
        ),
      ],
    );
  }
}
