import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

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
import '../../settings/settings_model.dart';
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
  });

  final Color iconColor;
  final PlayerPosition playerPosition;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    final mediaQuerySize = context.mediaQuerySize;
    final playerToTheRight = mediaQuerySize.width > kSideBarThreshHold;
    final playerWithSidePanel =
        playerPosition == PlayerPosition.fullWindow &&
        mediaQuerySize.width > 1000;
    final fullScreen = watchPropertyValue((AppModel m) => m.fullWindowMode);

    final showPlayerLyrics = watchPropertyValue(
      (SettingsModel m) => m.showPlayerLyrics,
    );
    final showQueue = watchPropertyValue((PlayerModel m) => m.showQueue);

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
          if (true) ...[
            IconButton(
              tooltip: audio?.isRadio == true
                  ? context.l10n.hearingHistory
                  : context.l10n.queue,
              icon: Icon(
                audio?.isRadio == true ? Iconz.radioHistory : Iconz.playlist,
                color: iconColor,
              ),
              isSelected: showQueue || playerWithSidePanel && !showPlayerLyrics,
              color: iconColor,
              onPressed: () {
                if (playerWithSidePanel) {
                  if (showPlayerLyrics) {
                    di<PlayerModel>().setShowQueue(true);
                    di<SettingsModel>().setShowPlayerLyrics(false);
                  }
                } else {
                  if (!showQueue && !showPlayerLyrics) {
                    di<PlayerModel>().setShowQueue(true);
                  } else if (showQueue) {
                    di<PlayerModel>().setShowQueue(false);
                  }
                }
              },
            ),
            IconButton(
              tooltip: context.l10n.lyrics,
              isSelected: showPlayerLyrics,
              onPressed: () {
                if (playerWithSidePanel) {
                  di<SettingsModel>().setShowPlayerLyrics(!showPlayerLyrics);
                  if (showQueue) {
                    di<PlayerModel>().setShowQueue(false);
                  }
                } else {
                  if (!showQueue && !showPlayerLyrics) {
                    di<SettingsModel>().setShowPlayerLyrics(true);
                  } else if (showPlayerLyrics) {
                    di<SettingsModel>().setShowPlayerLyrics(false);
                  }
                }
              },
              icon: Icon(Iconz.showLyrics),
            ),
          ],
          PlayerPauseTimerButton(iconColor: iconColor),
          ShareButton(audio: audio, active: active, color: iconColor),
          if (audio?.audioType == AudioType.podcast)
            PlaybackRateButton(active: active, color: iconColor),
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
        ],
      ),
    );
  }
}
