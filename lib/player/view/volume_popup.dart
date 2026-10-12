import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoenix_theme/phoenix_theme.dart' hide CustomTrackShape;

import '../../common/view/custom_track_shape.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../manager/volume_manager.dart';

class VolumeSliderPopup extends ConsumerWidget {
  const VolumeSliderPopup({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final volume = ref.watch(volumeManagerProvider);
    IconData iconData;
    if (volume != null && volume <= 0) {
      iconData = Iconz.speakerMutedFilled;
    } else if (volume != null && volume <= 20) {
      iconData = Iconz.speakerLowFilled;
    } else if (volume != null && volume <= 50 && volume > 20) {
      iconData = Iconz.speakerMediumFilled;
    } else {
      iconData = Iconz.speakerHighFilled;
    }
    return PopupMenuButton(
      color: theme.isLight
          ? theme.colorScheme.surface.scale(lightness: -0.04)
          : null,
      iconColor: color ?? theme.colorScheme.onSurface,
      padding: EdgeInsets.zero,
      tooltip: context.l10n.volume,
      icon: Icon(iconData, color: color ?? theme.colorScheme.onSurface),
      itemBuilder: (context) {
        return [const PopupMenuItem(enabled: false, child: VolumeSlider())];
      },
    );
  }
}

class VolumeSlider extends ConsumerWidget {
  const VolumeSlider({this.direction = Axis.vertical, super.key});

  final Axis direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(volumeManagerProvider);
    final slider = SliderTheme(
      data: context.theme.sliderTheme.copyWith(trackShape: CustomTrackShape()),
      child: Slider(
        value: volume ?? 100.0,
        onChanged: (val) =>
            ref.read(volumeManagerProvider.notifier).setVolume(val),
        max: 100,
        min: 0,
      ),
    );

    return direction == Axis.vertical
        ? RotatedBox(quarterTurns: 3, child: slider)
        : slider;
  }
}
