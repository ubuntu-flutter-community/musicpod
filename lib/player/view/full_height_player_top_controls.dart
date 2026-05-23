import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../app/app_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import 'playback_rate_button.dart';
import 'player_pause_timer_button.dart';
import 'player_view.dart';
import 'volume_popup.dart';

class FullHeightPlayerTopControls extends StatelessWidget with WatchItMixin {
  const FullHeightPlayerTopControls({
    super.key,
    required this.iconColor,
    required this.playerPosition,
    this.padding,
    this.video = false,
  });

  final Color iconColor;
  final PlayerPosition playerPosition;
  final EdgeInsetsGeometry? padding;
  final bool video;

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    final mediaQuerySize = context.mediaQuerySize;
    final playerWithSidePanel =
        playerPosition == PlayerPosition.fullWindow &&
        mediaQuerySize.width > 1000;
    final playerToTheRight = mediaQuerySize.width > kSideBarThreshHold;

    final fullWindowMode = watchValue((AppManager m) => m.fullWindowMode);
    final isFullScreen = isFullscreen(context);

    final showQueue = watchPropertyValue((PlayerModel m) => m.showQueue);

    final appManager = di<AppManager>();

    Future<void> onFullHeightButtonPressed() async {
      await appManager.setFullWindowMode(
        playerPosition == PlayerPosition.fullWindow ? false : true,
      );

      appManager.setShowWindowControls(
        (fullWindowMode && playerToTheRight) ? false : true,
      );
    }

    return Padding(
      padding: padding ?? playerTopControlsPadding,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 5.0,
        children: [
          if (!playerWithSidePanel && !video)
            IconButton(
              tooltip: audio?.isRadio == true
                  ? context.l10n.hearingHistory
                  : context.l10n.queue,
              icon: Icon(
                audio?.isRadio == true ? Iconz.radioHistory : Iconz.playlist,
                color: iconColor,
              ),
              isSelected: showQueue,
              color: iconColor,
              onPressed: di<PlayerModel>().toggleShowQueue,
            ),
          if (playerPosition == PlayerPosition.fullWindow)
            IconButton(
              tooltip: context.l10n.leaveFullWindow,
              icon: Icon(Iconz.fullWindowExit, color: iconColor),
              color: iconColor,
              onPressed: onFullHeightButtonPressed,
            ),
          if (audio?.audioType == AudioType.podcast && video)
            PlaybackRateButton(color: iconColor),
          if (video && !isMobile) VolumeSliderPopup(color: iconColor),
          if (video) PlayerPauseTimerButton(iconColor: iconColor),
          if (video && !isFullScreen)
            IconButton(
              tooltip: playerPosition == PlayerPosition.fullWindow
                  ? context.l10n.leaveFullWindow
                  : context.l10n.fullWindow,
              icon: Icon(
                playerPosition == PlayerPosition.fullWindow
                    ? Iconz.fullWindowExit
                    : Iconz.fullWindow,
                color: iconColor,
              ),
              onPressed: onFullHeightButtonPressed,
            ),
        ],
      ),
    );
  }
}
