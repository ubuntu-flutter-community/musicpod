import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/audio_signal_indicator.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../local_audio/manager/local_audio_manager.dart';
import '../../player/manager/current_audio_manager.dart';
import '../../player/manager/play_pause_manager.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';

class MainPageIcon extends ConsumerWidget {
  const MainPageIcon({
    super.key,
    required this.selected,
    required this.audioType,
  });

  final bool selected;
  final AudioType audioType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAudioType = ref.watch(
      currentAudioManagerProvider.select((m) => m?.audioType),
    );
    final isPlaying = ref.watch(playPauseManagerProvider);
    final useMoreAnimations =
        ref.watch(settingsBoolManagerProvider(SPKeys.useMoreAnimations)) ??
        false;

    if (audioType == AudioType.local) {
      return LocalMainPageIcon(
        isCurrentlyPlaying: currentAudioType == AudioType.local,
        selected: selected,
        isPlaying: isPlaying,
        useMoreAnimations: useMoreAnimations,
      );
    }

    if (currentAudioType == audioType) {
      if (isPlaying) {
        if (useMoreAnimations) {
          return const ActiveAudioSignalIndicator();
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
      child: Icon(selected ? audioType.selectedIconData : audioType.iconData),
    );
  }
}

class LocalMainPageIcon extends ConsumerWidget {
  const LocalMainPageIcon({
    super.key,
    required this.selected,
    required this.isPlaying,
    required this.useMoreAnimations,
    required this.isCurrentlyPlaying,
  });

  final bool selected;
  final bool isPlaying;
  final bool useMoreAnimations;
  final bool isCurrentlyPlaying;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocalAudioImporting = ref.watch(
      localAudioManagerProvider.select((s) => s.isLoading),
    );

    if (isLocalAudioImporting) {
      return Padding(
        padding: mainPageIconPadding,
        child: const SizedBox(
          width: 16,
          height: 16,
          child: Progress(strokeWidth: 2),
        ),
      );
    }

    if (useMoreAnimations && isCurrentlyPlaying && isPlaying) {
      return const ActiveAudioSignalIndicator(thickness: 2);
    }

    return Padding(
      padding: mainPageIconPadding,
      child: Icon(
        selected ? AudioType.local.selectedIconData : AudioType.local.iconData,
      ),
    );
  }
}
