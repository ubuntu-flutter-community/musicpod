import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../player.dart';
import 'blurred_full_height_player_image.dart';
import 'full_height_player_image.dart';
import 'full_height_player_top_controls.dart';
import 'full_height_title_and_artist.dart';

class FullHeightPlayer extends StatelessWidget {
  const FullHeightPlayer({
    super.key,
    required this.audio,
    required this.nextAudio,
    required this.playPrevious,
    required this.playNext,
    required this.playerViewMode,
    required this.videoController,
    required this.isVideo,
    required this.isOnline,
  });

  final Audio? audio;
  final Audio? nextAudio;
  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;

  final PlayerViewMode playerViewMode;

  final VideoController videoController;
  final bool isVideo;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final size = context.m.size;
    final playerToTheRight = size.width > kSideBarThreshHold;
    final appStateService = getService<AppStateService>();
    final fullScreen = appStateService.fullScreen;

    final active = audio?.path != null || isOnline;
    final activeControls = audio?.path != null || isOnline;

    final titleAndArtist = FullHeightTitleAndArtist(
      audio: audio,
    );

    const sliderAndTime = PlayerTrack();

    final iconColor = isVideo ? Colors.white : theme.colorScheme.onSurface;

    void onFullScreenPressed() {
      appStateService.setFullScreen(
        playerViewMode == PlayerViewMode.fullWindow ? false : true,
      );

      effect(
        () => appStateService.setShowWindowControls(
          (fullScreen.value == true && playerToTheRight) ? false : true,
        ),
      );
    }

    final body = Stack(
      alignment: Alignment.topRight,
      children: [
        if (isVideo)
          RepaintBoundary(
            child: Video(
              controller: videoController,
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
                  titleAndArtist,
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  const SizedBox(
                    height: kYaruPagePadding,
                    width: 400,
                    child: sliderAndTime,
                  ),
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  PlayerMainControls(
                    podcast: audio?.audioType == AudioType.podcast,
                    playPrevious: playPrevious,
                    playNext: playNext,
                    active: active,
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(
            right: kYaruPagePadding,
            top: Platform.isMacOS ? 0 : kYaruPagePadding,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: isVideo ? Colors.black.withOpacity(0.6) : null,
            ),
            child: FullHeightPlayerTopControls(
              audio: audio,
              iconColor: iconColor,
              activeControls: activeControls,
              playerViewMode: playerViewMode,
              onFullScreenPressed: onFullScreenPressed,
            ),
          ),
        ),
      ],
    );

    final fullHeightPlayer = Column(
      children: [
        if (!isMobile)
          HeaderBar(
            title: const Text(
              '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            foregroundColor: isVideo == true ? Colors.white : null,
            backgroundColor:
                isVideo == true ? Colors.black : Colors.transparent,
          ),
        isMobile
            ? Expanded(
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity != null &&
                        details.primaryVelocity! > 150) {
                      appStateService.setFullScreen(false);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: body,
                  ),
                ),
              )
            : Expanded(
                child: body,
              ),
      ],
    );

    if ((audio?.imageUrl != null ||
        audio?.albumArtUrl != null ||
        audio?.pictureData != null)) {
      return Stack(
        children: [
          BlurredFullHeightPlayerImage(
            size: size,
            audio: audio,
            isOnline: isOnline,
          ),
          fullHeightPlayer,
        ],
      );
    } else {
      return fullHeightPlayer;
    }
  }
}
