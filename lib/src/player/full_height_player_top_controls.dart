import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data.dart';
import '../../player.dart';
import 'playback_rate_button.dart';

class FullHeightPlayerTopControls extends StatelessWidget {
  const FullHeightPlayerTopControls({
    super.key,
    required this.audio,
    required this.iconColor,
    required this.activeControls,
    required this.playerViewMode,
    required this.onFullScreenPressed,
  });

  final Audio? audio;
  final Color iconColor;
  final bool activeControls;
  final PlayerViewMode playerViewMode;
  final void Function() onFullScreenPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 5.0,
      children: [
        LikeIconButton(
          audio: audio,
          color: iconColor,
        ),
        QueueButton(
          color: iconColor,
        ),
        ShareButton(
          audio: audio,
          active: activeControls,
          color: iconColor,
        ),
        if (audio?.audioType == AudioType.podcast)
          PlaybackRateButton(active: activeControls),
        VolumeSliderPopup(
          color: iconColor,
        ),
        IconButton(
          icon: Icon(
            playerViewMode == PlayerViewMode.fullWindow
                ? Iconz().fullScreenExit
                : Iconz().fullScreen,
            color: iconColor,
          ),
          onPressed: onFullScreenPressed,
        ),
      ],
    );
  }
}
