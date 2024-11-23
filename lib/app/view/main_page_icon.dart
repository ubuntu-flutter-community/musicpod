import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/audio_signal_indicator.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';
import '../../settings/settings_model.dart';

class MainPageIcon extends StatelessWidget with WatchItMixin {
  const MainPageIcon({
    super.key,
    required this.selected,
    required this.audioType,
  });

  final bool selected;
  final AudioType audioType;

  @override
  Widget build(BuildContext context) {
    final currentAudioType =
        watchPropertyValue((PlayerModel m) => m.audio?.audioType);
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final useMoreAnimations =
        watchPropertyValue((SettingsModel m) => m.useMoreAnimations);

    if (currentAudioType == audioType && isPlaying) {
      if (useMoreAnimations) {
        return ActiveAudioSignalIndicator(
          thickness: yaruStyled || appleStyled ? 1 : 2,
        );
      } else {
        return Padding(
          padding: mainPageIconPadding,
          child: Icon(
            Iconz.playFilled,
            color: context.colorScheme.primary,
          ),
        );
      }
    }

    return Padding(
      padding: mainPageIconPadding,
      child: Icon(selected ? audioType.selectedIconData : audioType.iconData),
    );
  }
}
