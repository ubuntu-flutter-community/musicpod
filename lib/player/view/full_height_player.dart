import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../app/connectivity_model.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';
import '../../radio/view/radio_history_list.dart';
import 'blurred_full_height_player_image.dart';
import 'full_height_player_image.dart';
import 'full_height_player_top_controls.dart';
import 'player_title_and_artist.dart';
import 'full_height_video_player.dart';
import 'player_main_controls.dart';
import 'player_track.dart';
import 'player_view.dart';
import 'queue_button.dart';

class FullHeightPlayer extends StatelessWidget with WatchItMixin {
  const FullHeightPlayer({
    super.key,
    required this.playerPosition,
  });

  final PlayerPosition playerPosition;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final size = context.mediaQuerySize;
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    final appModel = di<AppModel>();
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo == true);

    final active = audio?.path != null || isOnline;
    final iconColor = isVideo ? Colors.white : theme.colorScheme.onSurface;

    final playerWithSidePanel = playerPosition == PlayerPosition.fullWindow &&
        context.mediaQuerySize.width > 1000;

    final Widget bodyWithControls;
    if (isVideo) {
      bodyWithControls = FullHeightVideoPlayer(
        playerPosition: playerPosition,
      );
    } else {
      final column = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMobile || context.isPortrait) const FullHeightPlayerImage(),
          const SizedBox(
            height: kLargestSpace,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: PlayerTitleAndArtist(
              playerPosition: playerPosition,
            ),
          ),
          const SizedBox(
            height: kLargestSpace,
          ),
          SizedBox(
            height: kLargestSpace,
            width: playerWithSidePanel ? 400 : 350,
            child: const PlayerTrack(),
          ),
          const SizedBox(
            height: kLargestSpace,
          ),
          PlayerMainControls(active: active),
        ],
      );

      bodyWithControls = Stack(
        alignment: Alignment.topRight,
        children: [
          Center(
            child: playerWithSidePanel
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 490, child: column),
                      audio?.audioType == AudioType.radio
                          ? const SizedBox(
                              width: 400,
                              height: 500,
                              child: RadioHistoryList(
                                simpleList: true,
                              ),
                            )
                          : QueueBody(
                              advancedList: false,
                              selectedColor: theme.colorScheme.onSurface,
                            ),
                    ],
                  )
                : column,
          ),
          FullHeightPlayerTopControls(
            iconColor: iconColor,
            playerPosition: playerPosition,
          ),
        ],
      );
    }

    final body = isMobile
        ? GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 150) {
                appModel.setFullWindowMode(false);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: bodyWithControls,
            ),
          )
        : bodyWithControls;

    final headerBar = HeaderBar(
      adaptive: false,
      includeBackButton: false,
      includeSidebarButton: false,
      title: const Text(
        '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      foregroundColor: isVideo == true ? Colors.white : null,
      backgroundColor: isVideo == true ? Colors.black : Colors.transparent,
    );

    final fullHeightPlayer = isVideo
        ? Scaffold(
            backgroundColor: Colors.black,
            appBar: headerBar,
            body: body,
          )
        : Column(
            children: [
              if (!isMobile) headerBar,
              Expanded(
                child: body,
              ),
            ],
          );

    if (!isVideo) {
      return Stack(
        children: [
          BlurredFullHeightPlayerImage(size: size),
          fullHeightPlayer,
        ],
      );
    }

    return fullHeightPlayer;
  }
}
