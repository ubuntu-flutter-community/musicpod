import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/material.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/fullscreen.dart';

import '../../app/app_config.dart';
import '../../app/app_manager.dart';
import '../../app/connectivity_manager.dart';
import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/icons.dart';
import '../../common/view/search_button.dart';
import '../../common/view/share_button.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
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
    this.showQueueButon = true,
    this.showFullScreenButton = false,
  });

  final Color iconColor;
  final PlayerPosition playerPosition;
  final EdgeInsetsGeometry? padding;
  final bool showQueueButon;
  final bool showFullScreenButton;

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    final mediaQuerySize = context.mediaQuerySize;
    final playerToTheRight = mediaQuerySize.width > kSideBarThreshHold;

    final fullWindowMode = watchValue((AppManager m) => m.fullWindowMode);
    final isFullScreen = isFullscreen(context);

    final showQueue = watchPropertyValue((PlayerModel m) => m.showQueue);

    final appManager = di<AppManager>();
    final isOnline = watchValue(
      (ConnectivityManager m) =>
          m.connectivityCommand.select((p) => p.isOnline),
    );
    final active = audio?.path != null || isOnline;

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
          if (playerPosition == PlayerPosition.fullWindow)
            SearchButton(
              iconColor: iconColor,
              onPressed: () async {
                await onFullHeightButtonPressed();
                di<SearchModel>()
                  ..setSearchQuery('')
                  ..setAudioType(audio?.audioType);
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
              },
            ),
          if (showQueueButon)
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

          PlayerPauseTimerButton(iconColor: iconColor),
          ShareButton(audio: audio, active: active, color: iconColor),
          if (audio?.audioType == AudioType.podcast)
            PlaybackRateButton(color: iconColor),
          if (!isMobile) VolumeSliderPopup(color: iconColor),

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
          if (AppConfig.allowVideoFullScreen && showFullScreenButton)
            Tooltip(
              message: isFullScreen
                  ? context.l10n.leaveFullScreen
                  : context.l10n.fullScreen,
              child: MaterialFullscreenButton(
                icon: Icon(
                  isFullScreen ? Iconz.fullWindowExit : Iconz.fullWindow,
                  color: iconColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
