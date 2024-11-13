import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../radio/view/next_station_button.dart';
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
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.avatarPlayButton = true,
  });

  final bool active;
  final Color? iconColor, avatarColor;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool avatarPlayButton;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final defaultColor = iconColor ?? theme.colorScheme.onSurface;
    final queueLength = watchPropertyValue((PlayerModel m) => m.queue.length);
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final showSkipButtons =
        queueLength > 1 || audio?.audioType == AudioType.local;
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    final active = audio?.path != null || isOnline;

    final rawPlayButton = PlayButton(
      iconColor: iconColor ?? (theme.isLight ? Colors.white : Colors.black),
      active: active,
    );

    final playButton = avatarPlayButton
        ? CircleAvatar(
            radius: avatarIconRadius,
            backgroundColor:
                avatarColor ?? (theme.isLight ? Colors.black : Colors.white),
            child: SizedBox.square(
              dimension: 2 * avatarIconRadius,
              child: rawPlayButton,
            ),
          )
        : rawPlayButton;

    final children = <Widget>[
      switch (audio?.audioType) {
        AudioType.local => ShuffleButton(
            active: active,
            iconColor: defaultColor,
          ),
        AudioType.podcast => SeekButton(
            active: active,
            forward: false,
            iconColor: defaultColor,
          ),
        AudioType.radio => IconButton(
            tooltip: context.l10n.skipToLivStream,
            onPressed: di<PlayerModel>().playNext,
            icon: Icon(Iconz.refresh, color: defaultColor),
          ),
        _ => const SizedBox.shrink()
      },
      _flex,
      if (showSkipButtons)
        IconButton(
          tooltip: context.l10n.back,
          color: defaultColor,
          onPressed: !active ? null : () => di<PlayerModel>().playPrevious(),
          icon: Icon(
            Iconz.skipBackward,
            color: defaultColor,
          ),
        ),
      _flex,
      playButton,
      _flex,
      if (showSkipButtons)
        IconButton(
          tooltip: context.l10n.next,
          color: defaultColor,
          onPressed: !active || queueLength < 2
              ? null
              : () => di<PlayerModel>().playNext(),
          icon: Icon(
            Iconz.skipForward,
            color: defaultColor,
          ),
        ),
      _flex,
      switch (audio?.audioType) {
        AudioType.local => RepeatButton(
            active: active,
            iconColor: defaultColor,
          ),
        AudioType.podcast => SeekButton(
            active: active,
            iconColor: defaultColor,
          ),
        AudioType.radio => NextStationButton(
            iconColor: defaultColor,
          ),
        _ => const SizedBox.shrink(),
      },
    ];

    return Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      children: children,
    );
  }

  Flexible get _flex => const Flexible(
        child: SizedBox(
          width: 5,
        ),
      );
}
