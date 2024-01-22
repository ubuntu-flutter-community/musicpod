import 'package:flutter/material.dart';

import '../common/icons.dart';
import 'play_button.dart';
import 'playback_rate_button.dart';
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
    final children = <Widget>[
      if (showPlaybackRate)
        PlaybackRateButton(active: active)
      else
        ShuffleButton(active: active),
      _flex,
      SeekButton(
        active: active,
        forward: false,
      ),
      _flex,
      IconButton(
        onPressed: !active ? null : () => playPrevious(),
        icon: Icon(Iconz().skipBackward),
      ),
      _flex,
      PlayButton(active: active),
      _flex,
      IconButton(
        onPressed: !active ? null : () => playNext(),
        icon: Icon(Iconz().skipForward),
      ),
      _flex,
      SeekButton(active: active),
      _flex,
      RepeatButton(active: active),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Flexible get _flex => const Flexible(
        child: SizedBox(
          width: 5,
        ),
      );
}
