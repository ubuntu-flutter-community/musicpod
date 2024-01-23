import '../../common.dart';
import '../../data.dart';
import '../../player.dart';
import 'package:flutter/material.dart';

class FullHeightPlayerTopControls extends StatelessWidget {
  const FullHeightPlayerTopControls({
    super.key,
    required this.audio,
    required this.iconColor,
    required this.activeControls,
    required this.playerViewMode,
    required this.setFullScreen,
  });

  final Audio? audio;
  final Color iconColor;
  final bool activeControls;
  final PlayerViewMode playerViewMode;
  final void Function(bool? p1) setFullScreen;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 7.0,
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
          onPressed: () => setFullScreen(
            playerViewMode == PlayerViewMode.fullWindow ? false : true,
          ),
        ),
      ],
    );
  }
}
