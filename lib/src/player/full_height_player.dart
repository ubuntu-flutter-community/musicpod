import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../player.dart';
import 'blurred_full_height_player_image.dart';
import 'full_height_player_image.dart';
import 'full_height_player_top_controls.dart';
import 'full_height_title_and_artist.dart';
import 'up_next_bubble.dart';

class FullHeightPlayer extends StatelessWidget {
  const FullHeightPlayer({
    super.key,
    required this.audio,
    required this.nextAudio,
    required this.playPrevious,
    required this.playNext,
    required this.liked,
    required this.isStarredStation,
    required this.removeStarredStation,
    required this.addStarredStation,
    required this.removeLikedAudio,
    required this.addLikedAudio,
    required this.setFullScreen,
    required this.playerViewMode,
    required this.onTextTap,
    required this.videoController,
    required this.isVideo,
    required this.isOnline,
  });

  final Audio? audio;
  final Audio? nextAudio;
  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;
  final bool liked;

  final bool isStarredStation;
  final void Function(String station) removeStarredStation;
  final void Function(String name, Set<Audio> stations) addStarredStation;

  final void Function(Audio audio, bool notify) removeLikedAudio;
  final void Function(Audio audio, bool notify) addLikedAudio;

  final void Function(bool?) setFullScreen;

  final PlayerViewMode playerViewMode;

  final void Function({required String text, required AudioType audioType})
      onTextTap;

  final VideoController videoController;
  final bool isVideo;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final size = context.m.size;
    final active = audio?.path != null || isOnline;
    final activeControls = audio?.path != null || isOnline;

    final titleAndArtist = FullHeightTitleAndArtist(
      audio: audio,
      onTextTap: onTextTap,
    );

    final controls = FullHeightPlayerControls(
      audio: audio,
      playPrevious: playPrevious,
      playNext: playNext,
      active: active,
    );

    const sliderAndTime = PlayerTrack();

    final iconColor = isVideo ? Colors.white : theme.colorScheme.onSurface;
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
                  controls,
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
              liked: liked,
              isStarredStation: isStarredStation,
              removeStarredStation: removeStarredStation,
              addStarredStation: addStarredStation,
              removeLikedAudio: removeLikedAudio,
              addLikedAudio: addLikedAudio,
              iconColor: iconColor,
              activeControls: activeControls,
              playerViewMode: playerViewMode,
              setFullScreen: setFullScreen,
            ),
          ),
        ),
        if (nextAudio?.title != null &&
            nextAudio?.artist != null &&
            !isVideo &&
            size.width > 600)
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
                      setFullScreen(false);
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
