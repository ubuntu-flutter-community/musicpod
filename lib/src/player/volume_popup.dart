import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../l10n/l10n.dart';
import 'player_model.dart';

class VolumeSliderPopup extends StatelessWidget {
  const VolumeSliderPopup({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final playerModel = context.read<PlayerModel>();
    final volume = context.select((PlayerModel m) => m.volume);
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
      padding: EdgeInsets.zero,
      tooltip: context.l10n.volume,
      icon: Icon(
        iconData,
        color: color,
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            enabled: false,
            child: ChangeNotifierProvider.value(
              value: playerModel,
              builder: (context, _) {
                return _Slider(
                  setVolume: setVolume,
                );
              },
            ),
          ),
        ];
      },
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({
    required this.setVolume,
  });

  final Future<void> Function(double value) setVolume;

  @override
  Widget build(BuildContext context) {
    final volume = context.select((PlayerModel m) => m.volume);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Slider(
        value: volume,
        onChanged: setVolume,
        max: 100,
        min: 0,
      ),
    );
  }
}
