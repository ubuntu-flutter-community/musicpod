import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/player/player_track.dart';
import 'package:musicpod/data/audio.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'player_controls.dart';

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
  });

  final Audio? audio;
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

  final void Function({required String text, AudioType audioType}) onTextTap;

  final double volume;
  final Future<void> Function(double value) setVolume;

  final bool? isVideo;
  final VideoController videoController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData iconData;
    if (audio?.audioType == AudioType.radio) {
      iconData = YaruIcons.radio;
    } else if (audio?.audioType == AudioType.podcast) {
      iconData = YaruIcons.podcast;
    } else {
      iconData = YaruIcons.music_note;
    }

    final title = InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: audio?.audioType == null || audio?.title == null
          ? null
          : () => onTextTap(text: audio!.title!, audioType: audio!.audioType!),
      child: Text(
        audio?.title?.isNotEmpty == true ? audio!.title! : '',
        style: const TextStyle(
          fontWeight: FontWeight.w200,
          fontSize: 15,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Positioned(
            top: 12,
            right: 20,
            child: YaruIconButton(
              icon: Icon(
                YaruIcons.fullscreen,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () => setFullScreen(true),
            ),
          ),
          Row(
            children: [
              if (isVideo == true)
                RepaintBoundary(
                  child: Video(
                    height: 120,
                    width: 120,
                    filterQuality: FilterQuality.medium,
                    controller: videoController,
                    controls: (state) {
                      return const SizedBox.shrink();
                    },
                  ),
                )
              else if (audio?.pictureData != null)
                AnimatedContainer(
                  height: 120,
                  width: 120,
                  duration: const Duration(milliseconds: 300),
                  child: Image.memory(
                    filterQuality: FilterQuality.medium,
                    fit: BoxFit.cover,
                    audio!.pictureData!,
                    height: 120.0,
                  ),
                )
              else if (audio?.imageUrl != null || audio?.albumArtUrl != null)
                SizedBox(
                  height: 120,
                  width: 120,
                  child: SafeNetworkImage(
                    url: audio?.imageUrl ?? audio?.albumArtUrl,
                    filterQuality: FilterQuality.medium,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Icon(
                          iconData,
                          size: 80,
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 0,
                    )
                  ],
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kYaruPagePadding,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 45,
                        child: PlayerControls(
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
                          liked: liked,
                          isStarredStation: isStarredStation,
                          addStarredStation: addStarredStation,
                          removeStarredStation: removeStarredStation,
                          addLikedAudio: addLikedAudio,
                          removeLikedAudio: removeLikedAudio,
                          volume: volume,
                          setVolume: setVolume,
                        ),
                      ),
                      Expanded(
                        child: PlayerTrack(
                          color: color,
                          duration: duration,
                          position: position,
                          setPosition: setPosition,
                          seek: seek,
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: width * 0.75,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(flex: 1, child: title),
                              if (audio?.artist?.trim().isNotEmpty == true)
                                const SizedBox(
                                  width: 20,
                                  child: Text(' ・'),
                                ),
                              if (audio?.artist?.trim().isNotEmpty == true)
                                Flexible(
                                  flex: 1,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: audio?.audioType == null ||
                                            audio?.artist == null
                                        ? null
                                        : () => onTextTap(
                                              text: audio!.artist!,
                                              audioType: audio!.audioType!,
                                            ),
                                    child: Text(
                                      audio?.artist ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w100,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
