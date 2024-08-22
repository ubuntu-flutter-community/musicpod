import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../player_model.dart';
import 'play_button.dart';
import 'repeat_button.dart';
import 'seek_button.dart';
import 'shuffle_button.dart';

class PlayerMainControls extends StatelessWidget with WatchItMixin {
  const PlayerMainControls({
    super.key,
    required this.active,
    this.iconColor,
    this.avatarColor,
  });

  final bool active;
  final Color? iconColor, avatarColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final defaultColor = iconColor ?? theme.colorScheme.onSurface;
    final queueLength = watchPropertyValue((PlayerModel m) => m.queue.length);
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final showShuffleAndRepeat = audio?.audioType == AudioType.local;
    final showSkipButtons =
        queueLength > 1 || audio?.audioType == AudioType.local;
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    final active = audio?.path != null || isOnline;

    final children = <Widget>[
      if (showShuffleAndRepeat)
        ShuffleButton(active: active)
      else if (audio?.audioType == AudioType.podcast)
        SeekButton(
          active: active,
          forward: false,
          iconColor: defaultColor,
        ),
      _flex,
      if (showSkipButtons)
        IconButton(
          tooltip: context.l10n.back,
          color: defaultColor,
          onPressed: !active ? null : () => di<PlayerModel>().playPrevious(),
          icon: Icon(
            Iconz().skipBackward,
            color: defaultColor,
          ),
        ),
      _flex,
      CircleAvatar(
        radius: avatarIconSize,
        backgroundColor: avatarColor ?? theme.colorScheme.inverseSurface,
        child: PlayButton(
          iconColor: iconColor ?? theme.colorScheme.onInverseSurface,
          active: active,
        ),
      ),
      _flex,
      if (showSkipButtons)
        IconButton(
          tooltip: context.l10n.next,
          color: defaultColor,
          onPressed: !active || queueLength < 2
              ? null
              : () => di<PlayerModel>().playNext(),
          icon: Icon(
            Iconz().skipForward,
            color: defaultColor,
          ),
        ),
      _flex,
      if (showShuffleAndRepeat)
        RepeatButton(
          active: active,
          iconColor: defaultColor,
        )
      else if (audio?.audioType == AudioType.podcast)
        SeekButton(
          active: active,
          iconColor: defaultColor,
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
