import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:popover/popover.dart';

import '../../common.dart';
import '../../data.dart';
import '../../player.dart';
import '../globals.dart';

const _kBottomPlayerHeight = 90.0;

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({
    super.key,
    required this.setFullScreen,
    required this.audio,
    required this.width,
    this.color,
    this.duration,
    this.position,
    required this.setPosition,
    required this.seek,
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
  final Duration? duration;
  final Duration? position;
  final void Function(Duration?) setPosition;
  final Future<void> Function() seek;
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
    final verySmall = width < 700;

    final bottomPlayerImage = _BottomPlayerImage(
      audio: audio,
      size: _kBottomPlayerHeight - (verySmall ? 20 : 0),
      videoController: videoController,
      isVideo: isVideo,
      isOnline: isOnline,
    );

    final titleAndArtist = _BottomPlayerTitleArtist(
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
      color: color,
      duration: duration,
      position: position,
      setPosition: setPosition,
      seek: seek,
      superNarrow: verySmall,
    );

    if (verySmall) {
      return InkWell(
        onTap: () => setFullScreen(true),
        child: SizedBox(
          height: _kBottomPlayerHeight,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: bottomPlayerImage,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: titleAndArtist,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: IconButton(
                        onPressed:
                            !(audio?.path != null || isOnline) || audio == null
                                ? null
                                : () {
                                    if (isPlaying) {
                                      pause();
                                    } else {
                                      playOrPause();
                                    }
                                  },
                        icon: Icon(
                          isPlaying ? Iconz().pause : Iconz().play,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              track,
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: _kBottomPlayerHeight,
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

class _BottomPlayerTitleArtist extends StatelessWidget {
  const _BottomPlayerTitleArtist({
    required this.audio,
    required this.onTextTap,
    this.icyTitle,
    this.icyName,
  });

  final Audio? audio;
  final String? icyTitle;
  final String? icyName;
  final void Function(AudioType audioType, String text)? onTextTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => onTitleTap(
            audio: audio,
            title: icyTitle,
            context: context,
            onTextTap: onTextTap,
          ),
          child: Tooltip(
            message: icyTitle?.isNotEmpty == true
                ? icyTitle!
                : (audio?.title?.isNotEmpty == true ? audio!.title! : ' '),
            child: Text(
              icyTitle?.isNotEmpty == true
                  ? icyTitle!
                  : (audio?.title?.isNotEmpty == true ? audio!.title! : ' '),
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (audio?.artist?.trim().isNotEmpty == true ||
            icyName?.isNotEmpty == true)
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => onArtistTap(
              audio: audio,
              artist: icyTitle,
              context: context,
              onTextTap: onTextTap,
            ),
            child: Tooltip(
              message: icyName?.isNotEmpty == true
                  ? icyName!
                  : (audio?.artist ?? ' '),
              child: Text(
                icyName?.isNotEmpty == true ? icyName! : (audio?.artist ?? ' '),
                style: TextStyle(
                  fontWeight: smallTextFontWeight,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
      ],
    );
  }
}

class _BottomPlayerImage extends StatelessWidget {
  const _BottomPlayerImage({
    this.audio,
    required this.size,
    this.isVideo,
    required this.videoController,
    required this.isOnline,
  });
  final Audio? audio;
  final double size;
  final bool? isVideo;
  final VideoController videoController;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData iconData;
    if (audio?.audioType == AudioType.radio) {
      iconData = Iconz().radio;
    } else if (audio?.audioType == AudioType.podcast) {
      iconData = Iconz().podcast;
    } else {
      iconData = Iconz().musicNote;
    }
    if (isVideo == true) {
      return RepaintBoundary(
        child: Video(
          height: size,
          width: size,
          filterQuality: FilterQuality.medium,
          controller: videoController,
          controls: (state) {
            return const SizedBox.shrink();
          },
        ),
      );
    } else if (audio?.pictureData != null) {
      return AnimatedContainer(
        height: size,
        width: size,
        duration: const Duration(milliseconds: 300),
        child: Image.memory(
          filterQuality: FilterQuality.medium,
          fit: BoxFit.cover,
          audio!.pictureData!,
          height: size,
        ),
      );
    } else {
      if (!isOnline) {
        return SizedBox(
          width: size,
          height: size,
          child: Icon(
            iconData,
            size: 50,
            color: theme.hintColor,
          ),
        );
      } else if (audio?.imageUrl != null || audio?.albumArtUrl != null) {
        return SizedBox(
          height: size,
          width: size,
          child: SafeNetworkImage(
            errorIcon: Icon(
              iconData,
              size: 50,
              color: theme.hintColor,
            ),
            url: audio?.imageUrl ?? audio?.albumArtUrl,
            filterQuality: FilterQuality.medium,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              iconData,
              size: 50,
              color: theme.hintColor,
            ),
          ),
        );
      }
    }
  }
}
