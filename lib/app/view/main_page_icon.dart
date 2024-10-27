import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/audio_signal_indicator.dart';
import '../../common/view/icons.dart';
import '../../constants.dart';
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
        return const ActiveAudioSignalIndicator(thickness: 1);
      } else {
        return Padding(
          padding: kMainPageIconPadding,
          child: Icon(
            Iconz.playFilled,
            color: context.colorScheme.primary,
          ),
        );
      }
    }

    return Padding(
      padding: kMainPageIconPadding,
      child: switch (audioType) {
        AudioType.local =>
          selected ? Icon(Iconz.localAudioFilled) : Icon(Iconz.localAudio),
        AudioType.radio =>
          selected ? Icon(Iconz.radioFilled) : Icon(Iconz.radio),
        AudioType.podcast =>
          selected ? Icon(Iconz.podcastFilled) : Icon(Iconz.podcast),
      },
    );
  }
}
