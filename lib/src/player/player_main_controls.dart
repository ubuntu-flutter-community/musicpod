import 'package:flutter/material.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../get.dart';
import '../../l10n.dart';
import '../data/audio.dart';
import 'play_button.dart';
import 'player_model.dart';
import 'repeat_button.dart';
import 'seek_button.dart';
import 'shuffle_button.dart';

class PlayerMainControls extends StatelessWidget with WatchItMixin {
  const PlayerMainControls({
    super.key,
    required this.active,
    required this.playPrevious,
    required this.playNext,
  });

  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final defaultColor = theme.colorScheme.onSurface;
    final queueLength = watchPropertyValue((PlayerModel m) => m.queue.length);
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final showShuffleAndRepeat =
        queueLength < 2 ? false : (audio?.audioType != AudioType.podcast);
    final showSkipButtons = audio?.audioType == AudioType.local
        ? true
        : (queueLength < 2 ? false : audio?.audioType == AudioType.podcast);
    final isOnline = watchPropertyValue((AppModel m) => m.isOnline);
    final active = audio?.path != null || isOnline;

    final children = <Widget>[
      if (showShuffleAndRepeat)
        ShuffleButton(active: active)
      else if (audio?.audioType == AudioType.podcast)
        SeekButton(
          active: active,
          forward: false,
        ),
      _flex,
      if (showSkipButtons)
        IconButton(
          tooltip: context.l10n.back,
          color: defaultColor,
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
      if (showSkipButtons)
        IconButton(
          tooltip: context.l10n.next,
          color: defaultColor,
          onPressed: !active ? null : () => playNext(),
          icon: Icon(Iconz().skipForward),
        ),
      _flex,
      if (showShuffleAndRepeat)
        RepeatButton(active: active)
      else if (audio?.audioType == AudioType.podcast)
        SeekButton(
          active: active,
        ),
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
