import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:popover/popover.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../player.dart';
import 'bottom_player_image.dart';
import 'bottom_player_title_artist.dart';
import 'very_narrow_bottom_player.dart';

const kBottomPlayerHeight = 90.0;

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({
    super.key,
    required this.setFullScreen,
    required this.audio,
    required this.playPrevious,
    required this.playNext,
    required this.liked,
    required this.isStarredStation,
    required this.removeStarredStation,
    required this.addStarredStation,
    required this.removeLikedAudio,
    required this.addLikedAudio,
    required this.onTextTap,
    this.isVideo,
    required this.videoController,
    required this.isOnline,
  });

  final Audio? audio;

  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;
  final bool liked;

  final bool isStarredStation;
  final void Function(String station) removeStarredStation;
  final void Function(String name, Set<Audio> stations) addStarredStation;

  final void Function(Audio audio, bool notify) removeLikedAudio;
  final void Function(Audio audio, bool notify) addLikedAudio;

  final void Function(bool?) setFullScreen;

  final void Function({required String text, required AudioType audioType})
      onTextTap;

  final bool? isVideo;
  final VideoController videoController;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final veryNarrow = context.m.size.width < 700;
    final active = audio?.path != null || isOnline;

    final bottomPlayerImage = BottomPlayerImage(
      audio: audio,
      size: kBottomPlayerHeight - (veryNarrow ? 20 : 0),
      videoController: videoController,
      isVideo: isVideo,
      isOnline: isOnline,
    );

    final titleAndArtist = BottomPlayerTitleArtist(
      audio: audio,
      onTextTap: onTextTap,
    );

    final bottomPlayerControls = BottomPlayerControls(
      playPrevious: playPrevious,
      playNext: playNext,
      onFullScreenTap: () => setFullScreen(true),
      active: active,
    );

    final track = PlayerTrack(
      veryNarrow: veryNarrow,
      active: active,
    );

    if (veryNarrow) {
      final veryNarrowBottomPlayer = VeryNarrowBottomPlayer(
        setFullScreen: setFullScreen,
        bottomPlayerImage: bottomPlayerImage,
        titleAndArtist: titleAndArtist,
        active: active,
        isOnline: isOnline,
        track: track,
      );
      return isMobile
          ? GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < 150) {
                  setFullScreen(true);
                }
              },
              child: veryNarrowBottomPlayer,
            )
          : veryNarrowBottomPlayer;
    }

    return SizedBox(
      height: kBottomPlayerHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          bottomPlayerImage,
          const SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  flex: 3,
                  child: titleAndArtist,
                ),
                const SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: LikeIconButton(
                    audio: audio,
                    liked: liked,
                    isStarredStation: isStarredStation,
                    removeStarredStation: removeStarredStation,
                    addStarredStation: addStarredStation,
                    removeLikedAudio: removeLikedAudio,
                    addLikedAudio: addLikedAudio,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, right: 8),
              child: Column(
                children: [
                  bottomPlayerControls,
                  const SizedBox(
                    height: 8,
                  ),
                  track,
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const VolumeSliderPopup(
                  direction: PopoverDirection.top,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: QueueButton(),
                ),
                IconButton(
                  icon: Icon(
                    Iconz().fullScreen,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => setFullScreen(true),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
