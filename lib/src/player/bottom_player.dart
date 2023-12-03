import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:popover/popover.dart';

import '../../common.dart';
import '../../data.dart';
import '../../player.dart';
import '../globals.dart';
import 'bottom_player_image.dart';
import 'bottom_player_title_artist.dart';
import 'very_narrow_bottom_player.dart';

const kBottomPlayerHeight = 90.0;

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({
    super.key,
    required this.setFullScreen,
    required this.audio,
    required this.width,
    this.color,
    required this.repeatSingle,
    required this.setRepeatSingle,
    required this.shuffle,
    required this.setShuffle,
    required this.isPlaying,
    required this.playPrevious,
    required this.playNext,
    required this.pause,
    required this.playOrPause,
    required this.liked,
    required this.isStarredStation,
    required this.removeStarredStation,
    required this.addStarredStation,
    required this.removeLikedAudio,
    required this.addLikedAudio,
    required this.onTextTap,
    required this.setVolume,
    required this.volume,
    this.isVideo,
    required this.videoController,
    required this.queue,
    required this.isOnline,
    this.mpvMetaData,
  });

  final Audio? audio;
  final MpvMetaData? mpvMetaData;
  final List<Audio> queue;
  final double width;
  final Color? color;

  final bool repeatSingle;
  final void Function(bool) setRepeatSingle;
  final bool shuffle;
  final void Function(bool) setShuffle;
  final bool isPlaying;
  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;
  final Future<void> Function() pause;
  final Future<void> Function() playOrPause;
  final bool liked;

  final bool isStarredStation;
  final void Function(String station) removeStarredStation;
  final void Function(String name, Set<Audio> stations) addStarredStation;

  final void Function(Audio audio, bool notify) removeLikedAudio;
  final void Function(Audio audio, bool notify) addLikedAudio;

  final void Function(bool?) setFullScreen;

  final void Function({required String text, required AudioType audioType})
      onTextTap;

  final double volume;
  final Future<void> Function(double value) setVolume;

  final bool? isVideo;
  final VideoController videoController;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final veryNarrow = width < 700;

    final bottomPlayerImage = BottomPlayerImage(
      audio: audio,
      size: kBottomPlayerHeight - (veryNarrow ? 20 : 0),
      videoController: videoController,
      isVideo: isVideo,
      isOnline: isOnline,
    );

    final titleAndArtist = BottomPlayerTitleArtist(
      icyName: mpvMetaData?.icyName,
      icyTitle: mpvMetaData?.icyTitle,
      audio: audio,
      onTextTap: audio == null || audio?.audioType == null
          ? null
          : (audioType, text) {
              onTextTap(
                text: text,
                audioType: audio!.audioType!,
              );
              navigatorKey.currentState?.maybePop();
            },
    );

    final bottomPlayerControls = BottomPlayerControls(
      audio: audio,
      setRepeatSingle: setRepeatSingle,
      repeatSingle: repeatSingle,
      shuffle: shuffle,
      setShuffle: setShuffle,
      isPlaying: isPlaying,
      playPrevious: playPrevious,
      playNext: playNext,
      pause: pause,
      playOrPause: playOrPause,
      volume: volume,
      setVolume: setVolume,
      queue: queue,
      onFullScreenTap: () => setFullScreen(true),
      isOnline: isOnline,
    );

    final track = PlayerTrack(
      superNarrow: veryNarrow,
    );

    if (veryNarrow) {
      return VeryNarrowBottomPlayer(
        setFullScreen: setFullScreen,
        bottomPlayerImage: bottomPlayerImage,
        titleAndArtist: titleAndArtist,
        audio: audio,
        isOnline: isOnline,
        isPlaying: isPlaying,
        pause: pause,
        playOrPause: playOrPause,
        track: track,
      );
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
                VolumeSliderPopup(
                  volume: volume,
                  setVolume: setVolume,
                  direction: PopoverDirection.top,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: QueuePopup(
                    audio: audio,
                    queue: queue,
                  ),
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
