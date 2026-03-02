import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/audio_signal_indicator.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../local_audio/local_audio_model.dart';
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
    final currentAudioType = watchPropertyValue(
      (PlayerModel m) => m.audio?.audioType,
    );
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final useMoreAnimations = watchPropertyValue(
      (SettingsModel m) => m.useMoreAnimations,
    );
    final isLocalAudioImporting = watchValue(
      (LocalAudioModel m) => m.initAudiosCommand.isRunning,
    );

    if (currentAudioType == audioType) {
      if (isLocalAudioImporting) {
        return Padding(
          padding: mainPageIconPadding,
          child: const SizedBox(
            width: 16,
            height: 16,
            child: Progress(strokeWidth: 2),
          ),
        );
      } else if (isPlaying) {
        if (useMoreAnimations) {
          return const ActiveAudioSignalIndicator(thickness: 2);
        } else {
          return Padding(
            padding: mainPageIconPadding,
            child: Icon(Iconz.playFilled, color: context.colorScheme.primary),
          );
        }
      }
    }

    return Padding(
      padding: mainPageIconPadding,
      child: Icon(
        selected
            ? audioType.selectedIconDataMainPage
            : audioType.iconDataMainPage,
      ),
    );
  }
}
