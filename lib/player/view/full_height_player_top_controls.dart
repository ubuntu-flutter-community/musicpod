import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/app_model.dart';
import '../../app/connectivity_model.dart';
import '../../app/view/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/icons.dart';
import '../../common/view/like_icon_button.dart';
import '../../common/view/search_button.dart';
import '../../common/view/share_button.dart';
import '../../common/view/stared_station_icon_button.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/view/pin_album_button.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import 'playback_rate_button.dart';
import 'player_pause_timer_button.dart';
import 'player_view.dart';
import 'queue/queue_button.dart';
import 'volume_popup.dart';

class FullHeightPlayerTopControls extends StatelessWidget with WatchItMixin {
  const FullHeightPlayerTopControls({
    super.key,
    required this.iconColor,
    required this.playerPosition,
    this.padding,
    this.showQueueButton = true,
  });

  final Color iconColor;
  final PlayerPosition playerPosition;
  final EdgeInsetsGeometry? padding;
  final bool showQueueButton;

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    final playerToTheRight = context.mediaQuerySize.width > kSideBarThreshHold;
    final fullScreen = watchPropertyValue((AppModel m) => m.fullWindowMode);
    final showAudioVisualizer = watchPropertyValue(
      (PlayerModel m) => m.showAudioVisualizer,
    );
    final appModel = di<AppModel>();
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    final active = audio?.path != null || isOnline;

    Future<void> onFullHeightButtonPressed() async {
      await appModel.setFullWindowMode(
        playerPosition == PlayerPosition.fullWindow ? false : true,
      );

      appModel.setShowWindowControls(
        (fullScreen == true && playerToTheRight) ? false : true,
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
          if (audio?.audioType == AudioType.local && audio?.albumId != null)
            PinAlbumButton(albumId: audio!.albumId!),
          if (audio?.audioType != AudioType.podcast)
            switch (audio?.audioType) {
              AudioType.local => LikeIconButton(audio: audio, color: iconColor),
              AudioType.radio => StaredStationIconButton(
                audio: audio,
                color: iconColor,
              ),
              _ => const SizedBox.shrink(),
            },
          if (!isMobile && showQueueButton)
            QueueButton(
              color: iconColor,
              onTap: () => di<AppModel>().setOrToggleQueueOverlay(),
            ),
          PlayerPauseTimerButton(iconColor: iconColor),
          ShareButton(audio: audio, active: active, color: iconColor),
          if (audio?.audioType == AudioType.podcast)
            PlaybackRateButton(active: active, color: iconColor),
          if (!isMobile) VolumeSliderPopup(color: iconColor),
          if (kDebugMode)
            IconButton(
              onPressed: () =>
                  di<PlayerModel>().setShowAudioVisalizer(!showAudioVisualizer),
              icon: showAudioVisualizer
                  ? Icon(Iconz.show, color: iconColor)
                  : Icon(Iconz.hide, color: iconColor),
            ),
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
