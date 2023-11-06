import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data.dart';
import '../../player.dart';
import '../common/icons.dart';

class FullHeightPlayerControls extends StatelessWidget {
  const FullHeightPlayerControls({
    super.key,
    this.audio,
    required this.setRepeatSingle,
    required this.repeatSingle,
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
    required this.setVolume,
    required this.volume,
    required this.queue,
    required this.isOnline,
    this.expand = false,
  });

  final Audio? audio;
  final List<Audio> queue;
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
  final bool expand;

  final bool isStarredStation;
  final void Function(String station) removeStarredStation;
  final void Function(String name, Set<Audio> stations) addStarredStation;

  final void Function(Audio audio, bool notify) removeLikedAudio;
  final void Function(Audio audio, bool notify) addLikedAudio;
  final double volume;
  final Future<void> Function(double value) setVolume;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final active = audio?.path != null || isOnline;

    final spacing = expand ? 0.0 : 7.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LikeIconButton(
          audio: audio,
          liked: liked,
          isStarredStation: isStarredStation,
          removeStarredStation: removeStarredStation,
          addStarredStation: addStarredStation,
          removeLikedAudio: removeLikedAudio,
          addLikedAudio: addLikedAudio,
        ),
        SizedBox(
          width: spacing,
        ),
        if (!expand)
          ShareButton(
            active: active,
            audio: audio,
          ),
        SizedBox(
          width: spacing,
        ),
        IconButton(
          icon: Icon(
            Iconz().shuffle,
            color: !active
                ? theme.disabledColor
                : (shuffle
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface),
          ),
          onPressed: !active ? null : () => setShuffle(!(shuffle)),
        ),
        SizedBox(
          width: spacing,
        ),
        IconButton(
          onPressed: !active ? null : () => playPrevious(),
          icon: Icon(Iconz().skipBackward),
        ),
        SizedBox(
          width: spacing,
        ),
        IconButton(
          onPressed: !active || audio == null
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
        SizedBox(
          width: spacing,
        ),
        IconButton(
          onPressed: !active ? null : () => playNext(),
          icon: Icon(Iconz().skipForward),
        ),
        SizedBox(
          width: spacing,
        ),
        IconButton(
          icon: Icon(
            Iconz().repeatSingle,
            color: !active
                ? theme.disabledColor
                : (repeatSingle
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface),
          ),
          onPressed: !active ? null : () => setRepeatSingle(!(repeatSingle)),
        ),
        SizedBox(
          width: spacing,
        ),
        VolumeSliderPopup(volume: volume, setVolume: setVolume),
        if (!expand)
          SizedBox(
            width: spacing,
          ),
        if (!expand)
          QueuePopup(
            audio: audio,
            queue: queue,
          ),
      ],
    );
  }
}
