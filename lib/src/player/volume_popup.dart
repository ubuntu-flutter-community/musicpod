import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../../common.dart';
import '../l10n/l10n.dart';
import 'player_service.dart';

class VolumeSliderPopup extends StatelessWidget {
  const VolumeSliderPopup({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final service = getService<PlayerService>();
    final volume = service.volume.watch(context);
    final setVolume = service.setVolume;
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
            child: Watch.builder(
              builder: (context) {
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
    final service = getService<PlayerService>();
    final volume = service.volume.watch(context);

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
