import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

import '../../common.dart';
import '../l10n/l10n.dart';

class VolumeSliderPopup extends StatefulWidget {
  const VolumeSliderPopup({
    super.key,
    required this.volume,
    required this.setVolume,
    this.color,
  });

  final double volume;
  final Future<void> Function(double value) setVolume;
  final Color? color;

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

    final content = StatefulBuilder(
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
    );

    return IconButton(
      padding: EdgeInsets.zero,
      tooltip: context.l10n.volume,
      icon: Icon(
        iconData,
        color: widget.color,
      ),
      onPressed: () => showStyledPopover(
        context: context,
        content: content,
        height: 50,
        direction: PopoverDirection.top,
      ),
    );
  }
}
