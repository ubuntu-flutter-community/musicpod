import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaru/constants.dart';

import '../../common.dart';
import '../../data.dart';
import '../../l10n.dart';
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
    required this.isVideo,
  });

  final Audio? audio;
  final Color iconColor;
  final bool activeControls;
  final PlayerViewMode playerViewMode;
  final void Function() onFullScreenPressed;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: kYaruPagePadding,
        top: Platform.isMacOS ? 0 : kYaruPagePadding,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isVideo ? Colors.black.withOpacity(0.6) : null,
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: 5.0,
          children: [
            if (audio?.audioType != AudioType.podcast)
              PlayerLikeIcon(
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
              PlaybackRateButton(
                active: activeControls,
                color: iconColor,
              ),
            VolumeSliderPopup(
              color: iconColor,
            ),
            IconButton(
              tooltip: playerViewMode == PlayerViewMode.fullWindow
                  ? context.l10n.leaveFullWindow
                  : context.l10n.fullWindow,
              icon: Icon(
                playerViewMode == PlayerViewMode.fullWindow
                    ? Iconz().fullScreenExit
                    : Iconz().fullScreen,
                color: iconColor,
              ),
              onPressed: onFullScreenPressed,
            ),
          ],
        ),
      ),
    );
  }
}
