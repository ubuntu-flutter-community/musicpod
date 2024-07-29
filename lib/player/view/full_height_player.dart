import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../common/view/header_bar.dart';
import '../../extensions/build_context_x.dart';

import '../../player/player_model.dart';
import 'blurred_full_height_player_image.dart';
import 'full_height_player_image.dart';
import 'full_height_player_top_controls.dart';
import 'full_height_title_and_artist.dart';
import 'full_height_video_player.dart';
import 'player_main_controls.dart';
import 'player_track.dart';
import 'player_view.dart';
import 'up_next_bubble.dart';

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
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);
    final appModel = di<AppModel>();
    final nextAudio = watchPropertyValue((PlayerModel m) => m.nextAudio);
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo == true);
    final notAlone = watchPropertyValue((PlayerModel m) => m.queue.length > 1);
    final showUpNextBubble = notAlone &&
        nextAudio?.title != null &&
        nextAudio?.artist != null &&
        size.width > 600;
    final model = di<PlayerModel>();
    final active = audio?.path != null || isOnline;
    final iconColor = isVideo ? Colors.white : theme.colorScheme.onSurface;

    final Widget bodyWithControls;
    if (isVideo) {
      bodyWithControls = FullHeightVideoPlayer(
        playerPosition: playerPosition,
      );
    } else {
      bodyWithControls = Stack(
        alignment: Alignment.topRight,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FullHeightPlayerImage(
                    audio: audio,
                    isOnline: isOnline,
                  ),
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  FullHeightTitleAndArtist(
                    audio: audio,
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
                  PlayerMainControls(
                    playPrevious: model.playPrevious,
                    playNext: model.playNext,
                    active: active,
                  ),
                ],
              ),
            ),
          ),
          FullHeightPlayerTopControls(
            iconColor: iconColor,
            playerPosition: playerPosition,
          ),
          if (showUpNextBubble)
            Positioned(
              left: 10,
              bottom: 10,
              child: UpNextBubble(
                audio: audio,
                nextAudio: nextAudio,
              ),
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
          BlurredFullHeightPlayerImage(
            size: size,
            audio: audio,
          ),
          fullHeightPlayer,
        ],
      );
    }

    return fullHeightPlayer;
  }
}
