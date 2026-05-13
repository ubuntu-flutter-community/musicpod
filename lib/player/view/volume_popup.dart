import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart' hide CustomTrackShape;
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';

import '../../common/view/custom_track_shape.dart';
import '../../l10n/l10n.dart';
import '../player_model.dart';

class VolumeSliderPopup extends StatelessWidget with WatchItMixin {
  const VolumeSliderPopup({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final volume = watchPropertyValue((PlayerModel m) => m.volume);
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

class VolumeSlider extends StatelessWidget with WatchItMixin {
  const VolumeSlider({this.direction = Axis.vertical, super.key});

  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final volume = watchPropertyValue((PlayerModel m) => m.volume);
    final slider = SliderTheme(
      data: context.theme.sliderTheme.copyWith(trackShape: CustomTrackShape()),
      child: Slider(
        value: volume ?? 100.0,
        onChanged: di<PlayerModel>().setVolume,
        max: 100,
        min: 0,
      ),
    );

    return direction == Axis.vertical
        ? RotatedBox(quarterTurns: 3, child: slider)
        : slider;
  }
}
