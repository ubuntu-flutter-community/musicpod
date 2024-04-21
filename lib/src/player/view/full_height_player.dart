import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:yaru/yaru.dart';

import '../../../app.dart';
import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../get.dart';
import '../../../player.dart';
import 'blurred_full_height_player_image.dart';
import 'full_height_player_image.dart';
import 'full_height_player_top_controls.dart';
import 'full_height_title_and_artist.dart';
import 'player_main_controls.dart';
import 'player_track.dart';
import 'up_next_bubble.dart';

class FullHeightPlayer extends StatelessWidget with WatchItMixin {
  const FullHeightPlayer({
    super.key,
    required this.playerViewMode,
  });

  final PlayerViewMode playerViewMode;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final size = context.m.size;
    final isOnline = watchPropertyValue((AppModel m) => m.isOnline);
    final appModel = getIt<AppModel>();
    final nextAudio = watchPropertyValue((PlayerModel m) => m.nextAudio);
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo == true);
    final notAlone = watchPropertyValue((PlayerModel m) => m.queue.length > 1);
    final showUpNextBubble = notAlone &&
        nextAudio?.title != null &&
        nextAudio?.artist != null &&
        !isVideo &&
        size.width > 600;
    final model = getIt<PlayerModel>();
    final active = audio?.path != null || isOnline;
    final iconColor = isVideo ? Colors.white : theme.colorScheme.onSurface;

    final bodyWithControls = Stack(
      alignment: Alignment.topRight,
      children: [
        if (isVideo)
          RepaintBoundary(
            child: Video(
              controller: model.controller,
            ),
          )
        else
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
          playerViewMode: playerViewMode,
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

    final body = isMobile
        ? GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 150) {
                appModel.setFullScreen(false);
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

    if ((audio?.imageUrl != null ||
            audio?.albumArtUrl != null ||
            audio?.pictureData != null) &&
        isOnline &&
        !isVideo) {
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
