import 'package:flutter/material.dart';

import '../common/icons.dart';
import 'playback_rate_button.dart';
import 'play_button.dart';
import 'repeat_button.dart';
import 'seek_button.dart';
import 'shuffle_button.dart';

class BottomPlayerControls extends StatelessWidget {
  const BottomPlayerControls({
    super.key,
    required this.active,
    required this.playPrevious,
    required this.playNext,
    required this.onFullScreenTap,
    required this.showPlaybackRate,
  });

  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;

  final void Function() onFullScreenTap;

  final bool active;
  final bool showPlaybackRate;

  @override
  Widget build(BuildContext context) {
    final children = [
      Wrap(
        spacing: 5,
        children: [
          if (showPlaybackRate)
            PlaybackRateButton(active: active)
          else
            ShuffleButton(active: active),
          SeekButton(
            active: active,
            forward: false,
          ),
          IconButton(
            onPressed: !active ? null : () => playPrevious(),
            icon: Icon(Iconz().skipBackward),
          ),
          PlayButton(active: active),
          IconButton(
            onPressed: !active ? null : () => playNext(),
            icon: Icon(Iconz().skipForward),
          ),
          SeekButton(active: active),
          RepeatButton(active: active),
          const SizedBox(
            width: 0,
          ),
        ],
      ),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
