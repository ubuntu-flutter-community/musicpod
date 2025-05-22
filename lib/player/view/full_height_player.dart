import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/app_model.dart';
import '../../app/connectivity_model.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../player/player_model.dart';
import '../../radio/view/radio_history_list.dart';
import 'full_height_player_image.dart';
import 'full_height_player_top_controls.dart';
import 'full_height_video_player.dart';
import 'player_color.dart';
import 'player_main_controls.dart';
import 'player_title_and_artist.dart';
import 'player_track.dart';
import 'player_view.dart';
import 'queue/queue_body.dart';
import 'queue/queue_button.dart';

class FullHeightPlayer extends StatelessWidget with WatchItMixin {
  const FullHeightPlayer({super.key, required this.playerPosition});

  final PlayerPosition playerPosition;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final size = context.mediaQuerySize;
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo == true);
    final active = audio?.path != null || isOnline;
    final iconColor = isVideo ? Colors.white : theme.colorScheme.onSurface;
    final showQueue = watchPropertyValue((AppModel m) => m.showQueueOverlay);
    final playerWithSidePanel =
        playerPosition == PlayerPosition.fullWindow &&
        context.mediaQuerySize.width > 1000;

    final Widget body;
    if (isVideo) {
      body = FullHeightVideoPlayer(playerPosition: playerPosition);
    } else {
      final queueOrHistory = audio?.audioType == AudioType.radio
          ? const SizedBox(
              width: 400,
              height: 500,
              child: RadioHistoryList(simpleList: true),
            )
          : QueueBody(selectedColor: theme.colorScheme.onSurface);
      final column = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showQueue && !playerWithSidePanel)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 2 * kLargestSpace,
                top: kLargestSpace,
              ),
              child: queueOrHistory,
            )
          else ...[
            if (!isMobile || context.isPortrait)
              const Hero(
                tag: 'FullHeightPlayerImageInPortrait',
                child: FullHeightPlayerImage(),
              ),
            const SizedBox(height: kLargestSpace),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: PlayerTitleAndArtist(playerPosition: playerPosition),
            ),
            const SizedBox(height: kLargestSpace),
            SizedBox(
              height: kLargestSpace,
              width: playerWithSidePanel ? 400 : 350,
              child: const PlayerTrack(),
            ),
            const SizedBox(height: kLargestSpace),
          ],
          SizedBox(
            width: playerWithSidePanel ? 400 : 320,
            child: PlayerMainControls(active: active),
          ),
        ],
      );

      body = Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: playerWithSidePanel
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 490, child: column),
                      queueOrHistory,
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
                        child: FullHeightPlayerImage(height: 200, width: 200),
                      ),
                      SizedBox(width: 400, child: column),
                    ],
                  )
                : column,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: FullHeightPlayerTopControls(
              iconColor: iconColor,
              playerPosition: playerPosition,
              showQueueButton: !playerWithSidePanel,
            ),
          ),
          if (isMobile)
            const Positioned(
              bottom: 2 * kLargestSpace,
              child: QueueButton.text(),
            ),
        ],
      );
    }

    final headerBar = HeaderBar(
      adaptive: false,
      includeBackButton: false,
      includeSidebarButton: false,
      title: const Text('', maxLines: 1, overflow: TextOverflow.ellipsis),
      foregroundColor: isVideo == true ? Colors.white : null,
      backgroundColor: isVideo == true ? Colors.black : Colors.transparent,
    );

    final fullHeightPlayer = Column(
      children: [
        if (!isMobile) headerBar,
        Expanded(child: body),
      ],
    );

    if (isVideo) {
      return fullHeightPlayer;
    }

    return Stack(
      children: [
        PlayerColor(alpha: 0.4, size: size, position: playerPosition),
        fullHeightPlayer,
      ],
    );
  }
}
