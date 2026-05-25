import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/share_button.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../player_model.dart';
import 'bottom_player_like_and_star_button.dart';
import 'full_height_player_image.dart';
import 'playback_rate_button.dart';
import 'player_explorer.dart';
import 'player_main_controls.dart';
import 'player_pause_timer_button.dart';
import 'player_title_and_artist.dart';
import 'player_track.dart';
import 'player_view.dart';
import 'stop_button.dart';
import 'volume_popup.dart';

class FullHeightPlayerAudioBody extends StatelessWidget with WatchItMixin {
  const FullHeightPlayerAudioBody({
    super.key,
    this.audio,
    required this.active,
    required this.iconColor,
  });

  final Audio? audio;
  final bool active;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final mediaQuerySize = context.mediaQuerySize;

    final showQueue = watchPropertyValue((PlayerModel m) => m.showQueue);

    final playerWithSidePanel = mediaQuerySize.width > 2 * kPlayerExplorerWidth;

    final queueOrHistory = Padding(
      padding: EdgeInsets.only(
        top: isMobile ? 90 : kLargestSpace,
        bottom: kLargestSpace,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: kPlayerExplorerWidth,
          maxHeight: mediaQuerySize.height - 0.3 * mediaQuerySize.height,
        ),
        child: PlayerExplorer(selectedColor: theme.colorScheme.onSurface),
      ),
    );

    final column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showQueue && !playerWithSidePanel) ...[
          Expanded(child: queueOrHistory),
        ] else ...[
          if (!isMobile || context.isPortrait)
            const Hero(
              tag: 'FullHeightPlayerImageInPortrait',
              child: FullHeightPlayerImage(),
            ),
          const SizedBox(height: kLargestSpace),
        ],
        if (isMobile) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: PlayerTitleAndArtist(
                    playerPosition: PlayerPosition.fullWindow,
                  ),
                ),
                const BottomPlayerLikeAndStarButton(),
              ],
            ),
          ),
          const SizedBox(height: kLargestSpace),
          SizedBox(
            height: kLargestSpace,
            width: playerWithSidePanel ? kPlayerExplorerWidth : 350,
            child: const PlayerTrack(),
          ),
          const SizedBox(height: kLargestSpace),
          SizedBox(
            width: playerWithSidePanel ? kPlayerExplorerWidth : 320,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: showQueue && !playerWithSidePanel
                    ? 4 * kLargestSpace
                    : 0,
              ),
              child: PlayerMainControls(active: active),
            ),
          ),
          const SizedBox(height: kLargestSpace),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: kMediumSpace,
            children: [
              if (audio?.audioType == AudioType.podcast)
                PlaybackRateButton(color: iconColor),
              if (!isMobile) VolumeSliderPopup(color: iconColor),
              PlayerPauseTimerButton(iconColor: iconColor),
              ShareButton(active: active),
              StopButton(active: active),
            ],
          ),
          const SizedBox(height: kLargestSpace),
        ],
      ],
    );

    return Center(
      child: playerWithSidePanel
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: kPlayerExplorerWidth, child: column),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3 * kLargestSpace),
                  child: queueOrHistory,
                ),
              ],
            )
          : isMobile && !context.isPortrait
          ? Row(
              spacing: kLargestSpace,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Hero(
                  tag: 'FullHeightPlayerImageInLandscape',
                  child: FullHeightPlayerImage(),
                ),
                SizedBox(width: kPlayerExplorerWidth, child: column),
              ],
            )
          : column,
    );
  }
}
