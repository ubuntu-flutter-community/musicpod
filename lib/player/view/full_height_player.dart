import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../app/connectivity_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/header_bar.dart';
import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';
import '../../radio/view/radio_history_list.dart';
import 'blurred_full_height_player_image.dart';
import 'full_height_player_image.dart';
import 'full_height_player_top_controls.dart';
import 'full_height_title_and_artist.dart';
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
    final theme = context.t;
    final size = context.m.size;
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    final appModel = di<AppModel>();
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo == true);

    final active = audio?.path != null || isOnline;
    final iconColor = isVideo ? Colors.white : theme.colorScheme.onSurface;

    final playerWithSidePanel = playerPosition == PlayerPosition.fullWindow &&
        context.m.size.width > 1000;

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
          const FullHeightPlayerImage(),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: FullHeightTitleAndArtist(
              audio: audio,
            ),
          ),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          const SizedBox(
            height: kYaruPagePadding,
            width: 400,
            child: PlayerTrack(),
          ),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          PlayerMainControls(active: active),
        ],
      );

      bodyWithControls = Stack(
        alignment: Alignment.topRight,
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 490, child: column),
                if (playerWithSidePanel)
                  audio?.audioType == AudioType.radio
                      ? const SizedBox(
                          width: 400,
                          height: 500,
                          child: RadioHistoryList(
                            simpleList: true,
                          ),
                        )
                      : const QueueBody(advancedList: false),
              ],
            ),
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
