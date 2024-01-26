import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../player.dart';
import 'bottom_player_image.dart';
import 'bottom_player_title_artist.dart';
import 'play_button.dart';
import 'playback_rate_button.dart';

const kBottomPlayerHeight = 90.0;

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({
    super.key,
    required this.setFullScreen,
    required this.audio,
    required this.playPrevious,
    required this.playNext,
    this.isVideo,
    required this.videoController,
    required this.isOnline,
  });

  final Audio? audio;

  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;

  final void Function(bool?) setFullScreen;

  final bool? isVideo;
  final VideoController videoController;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final veryNarrow = context.m.size.width < kMasterDetailBreakPoint;
    final active = audio?.path != null || isOnline;

    final bottomPlayerImage = ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: BottomPlayerImage(
        audio: audio,
        size: kBottomPlayerHeight - 24,
        videoController: videoController,
        isVideo: isVideo,
        isOnline: isOnline,
      ),
    );

    final titleAndArtist = BottomPlayerTitleArtist(
      audio: audio,
    );

    final bottomPlayerControls = BottomPlayerControls(
      playPrevious: playPrevious,
      playNext: playNext,
      onFullScreenTap: () => setFullScreen(true),
      active: active,
      podcast: audio?.audioType == AudioType.podcast,
    );

    final track = PlayerTrack(
      active: active,
      bottomPlayer: true,
    );

    final bottom = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 20),
            child: bottomPlayerImage,
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Flexible(
                  flex: 5,
                  child: titleAndArtist,
                ),
                if (audio?.audioType != AudioType.podcast && !veryNarrow)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: LikeIconButton(
                        audio: audio,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!veryNarrow)
            Expanded(
              flex: 6,
              child: bottomPlayerControls,
            ),
          if (!veryNarrow)
            Flexible(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (audio?.audioType == AudioType.podcast)
                    PlaybackRateButton(active: active),
                  const VolumeSliderPopup(),
                  const QueueButton(),
                  IconButton(
                    icon: Icon(
                      Iconz().fullScreen,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: () => setFullScreen(true),
                  ),
                ],
              ),
            )
          else
            PlayButton(active: active),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );

    final player = SizedBox(
      height: kBottomPlayerHeight,
      child: Column(
        children: [
          track,
          if (veryNarrow)
            InkWell(
              onTap: () => setFullScreen(true),
              child: bottom,
            )
          else
            bottom,
        ],
      ),
    );

    if (isMobile) {
      return GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! < 150) {
            setFullScreen(true);
          }
        },
        child: player,
      );
    }

    return player;
  }
}
