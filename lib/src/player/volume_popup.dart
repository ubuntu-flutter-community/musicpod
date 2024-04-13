import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../get.dart';
import '../l10n/l10n.dart';
import 'player_model.dart';

class VolumeSliderPopup extends StatelessWidget with WatchItMixin {
  const VolumeSliderPopup({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final playerModel = getIt<PlayerModel>();
    final volume = watchPropertyValue((PlayerModel m) => m.volume);
    final setVolume = playerModel.setVolume;
    IconData iconData;
    if (volume <= 0) {
      iconData = Iconz().speakerMutedFilled;
    } else if (volume <= 20) {
      iconData = Iconz().speakerLowFilled;
    } else if (volume <= 50 && volume > 20) {
      iconData = Iconz().speakerMediumFilled;
    } else {
      iconData = Iconz().speakerHighFilled;
    }

    return PopupMenuButton(
      iconColor: color ?? theme.colorScheme.onSurface,
      padding: EdgeInsets.zero,
      tooltip: context.l10n.volume,
      icon: Icon(
        iconData,
        color: color ?? theme.colorScheme.onSurface,
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            enabled: false,
            child: _Slider(
              setVolume: setVolume,
            ),
          ),
        ];
      },
    );
  }
}

class _Slider extends StatelessWidget with WatchItMixin {
  const _Slider({
    required this.setVolume,
  });

  final Future<void> Function(double value) setVolume;

  @override
  Widget build(BuildContext context) {
    final volume = watchPropertyValue((PlayerModel m) => m.volume);
    return RotatedBox(
      quarterTurns: 3,
      child: Slider(
        value: volume,
        onChanged: setVolume,
        max: 100,
        min: 0,
      ),
    );
  }
}
