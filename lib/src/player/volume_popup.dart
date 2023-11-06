import 'package:flutter/material.dart';
import '../common/icons.dart';

import '../l10n/l10n.dart';

class VolumeSliderPopup extends StatefulWidget {
  const VolumeSliderPopup({
    super.key,
    required this.volume,
    required this.setVolume,
  });

  final double volume;
  final Future<void> Function(double value) setVolume;

  @override
  State<VolumeSliderPopup> createState() => _VolumeSliderPopupState();
}

class _VolumeSliderPopupState extends State<VolumeSliderPopup> {
  @override
  Widget build(BuildContext context) {
    IconData iconData;
    if (widget.volume <= 20) {
      iconData = Iconz().speakerLowFilled;
    } else if (widget.volume <= 50 && widget.volume > 20) {
      iconData = Iconz().speakerMediumFilled;
    } else if (widget.volume <= 0) {
      iconData = Iconz().speakerMutedFilled;
    } else {
      iconData = Iconz().speakerHighFilled;
    }

    return StatefulBuilder(
      builder: (context, stateSetter) {
        return PopupMenuButton<double>(
          padding: EdgeInsets.zero,
          tooltip: context.l10n.volume,
          icon: Icon(iconData),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: StatefulBuilder(
                  builder: (context, stateSetter) {
                    return Slider(
                      value: widget.volume,
                      onChanged: (value) async {
                        await widget.setVolume(value);
                        stateSetter(
                          () {},
                        );
                      },
                      max: 100,
                      min: 0,
                    );
                  },
                ),
              ),
            ];
          },
        );
      },
    );
  }
}
