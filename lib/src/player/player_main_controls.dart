import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import 'play_button.dart';
import 'repeat_button.dart';
import 'seek_button.dart';
import 'shuffle_button.dart';

class PlayerMainControls extends StatelessWidget {
  const PlayerMainControls({
    super.key,
    required this.active,
    required this.playPrevious,
    required this.playNext,
    required this.podcast,
  });

  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;

  final bool active;
  final bool podcast;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final children = <Widget>[
      if (podcast)
        SeekButton(
          active: active,
          forward: false,
        )
      else
        ShuffleButton(active: active),
      _flex,
      IconButton(
        onPressed: !active ? null : () => playPrevious(),
        icon: Icon(Iconz().skipBackward),
      ),
      _flex,
      CircleAvatar(
        radius: avatarIconSize,
        backgroundColor: theme.colorScheme.inverseSurface,
        child: PlayButton(
          iconColor: theme.colorScheme.onInverseSurface,
          active: active,
        ),
      ),
      _flex,
      IconButton(
        onPressed: !active ? null : () => playNext(),
        icon: Icon(Iconz().skipForward),
      ),
      _flex,
      if (podcast) SeekButton(active: active) else RepeatButton(active: active),
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
