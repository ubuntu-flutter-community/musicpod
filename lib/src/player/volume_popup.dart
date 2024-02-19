import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common.dart';
import '../l10n/l10n.dart';
import 'player_model.dart';

class VolumeSliderPopup extends ConsumerWidget {
  const VolumeSliderPopup({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerModel = ref.read(playerModelProvider);
    final volume = ref.watch(playerModelProvider.select((m) => m.volume));
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
            child: _Slider(
              setVolume: setVolume,
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Consumer(
        builder: (context, ref, _) {
          final volume = ref.watch(playerModelProvider.select((m) => m.volume));

          return Slider(
            value: volume,
            onChanged: setVolume,
            max: 100,
            min: 0,
          );
        },
      ),
    );
  }
}
