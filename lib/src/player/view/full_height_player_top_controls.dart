import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaru/constants.dart';

import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../constants.dart';
import '../../../data.dart';
import '../../../get.dart';
import '../../../l10n.dart';
import '../../../player.dart';
import '../../app/app_model.dart';
import 'playback_rate_button.dart';
import 'player_like_icon.dart';
import 'queue_button.dart';
import 'volume_popup.dart';

class FullHeightPlayerTopControls extends StatelessWidget with WatchItMixin {
  const FullHeightPlayerTopControls({
    super.key,
    required this.iconColor,
    required this.playerViewMode,
  });

  final Color iconColor;
  final PlayerViewMode playerViewMode;

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final showQueueButton = watchPropertyValue(
      (PlayerModel m) =>
          m.queue.length > 1 || audio?.audioType == AudioType.local,
    );
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo == true);
    final playerToTheRight = context.m.size.width > kSideBarThreshHold;
    final fullScreen = watchPropertyValue((AppModel m) => m.fullScreen);
    final appModel = getIt<AppModel>();
    final isOnline = watchPropertyValue((AppModel m) => m.isOnline);
    final active = audio?.path != null || isOnline;

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
            if (showQueueButton) QueueButton(color: iconColor),
            ShareButton(
              audio: audio,
              active: active,
              color: iconColor,
            ),
            if (audio?.audioType == AudioType.podcast)
              PlaybackRateButton(
                active: active,
                color: iconColor,
              ),
            VolumeSliderPopup(color: iconColor),
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
              onPressed: () {
                appModel.setFullScreen(
                  playerViewMode == PlayerViewMode.fullWindow ? false : true,
                );

                appModel.setShowWindowControls(
                  (fullScreen == true && playerToTheRight) ? false : true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
