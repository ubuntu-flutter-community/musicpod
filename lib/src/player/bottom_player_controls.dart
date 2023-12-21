import 'package:flutter/material.dart';

import '../common/icons.dart';
import 'play_button.dart';
import 'repeat_button.dart';
import 'shuffle_button.dart';

class BottomPlayerControls extends StatelessWidget {
  const BottomPlayerControls({
    super.key,
    required this.active,
    required this.playPrevious,
    required this.playNext,
    required this.onFullScreenTap,
  });

  final Future<void> Function({bool doubleTap}) playPrevious;
  final Future<void> Function() playNext;

  final void Function() onFullScreenTap;

  final bool active;

  @override
  Widget build(BuildContext context) {
    final children = [
      Row(
        children: [
          ShuffleButton(active: active),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onDoubleTap: !active ? null : () => playPrevious(doubleTap: true),
              child: IconButton(
                onPressed: !active ? null : () => playPrevious(),
                icon: Icon(Iconz().skipBackward),
              ),
            ),
          ),
          PlayButton(active: active),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              onPressed: !active ? null : () => playNext(),
              icon: Icon(Iconz().skipForward),
            ),
          ),
          RepeatButton(active: active),
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
