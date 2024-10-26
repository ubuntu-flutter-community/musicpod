import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/audio_type_is_playing_indicator.dart';
import '../../common/view/icons.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';
import '../../settings/settings_model.dart';

class RadioPageIcon extends StatelessWidget with WatchItMixin {
  const RadioPageIcon({
    super.key,
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final audioType = watchPropertyValue((PlayerModel m) => m.audio?.audioType);
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final useMoreAnimations =
        watchPropertyValue((SettingsModel m) => m.useMoreAnimations);

    if (useMoreAnimations && audioType == AudioType.radio) {
      if (isPlaying) {
        return const AudioTypeIsPlayingIndicator(thickness: 1);
      } else {
        return Icon(
          Iconz.playFilled,
          color: context.colorScheme.primary,
        );
      }
    }

    return Padding(
      padding: kMainPageIconPadding,
      child: selected ? Icon(Iconz.radioFilled) : Icon(Iconz.radio),
    );
  }
}
