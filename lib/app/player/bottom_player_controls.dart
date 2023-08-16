import 'package:flutter/material.dart';
import 'package:musicpod/data/audio.dart';
import 'package:yaru_icons/yaru_icons.dart';

class BottomPlayerControls extends StatelessWidget {
  const BottomPlayerControls({
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
    required this.setVolume,
    required this.volume,
    required this.queue,
    required this.onFullScreenTap,
    required this.isOnline,
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

  final double volume;
  final Future<void> Function(double value) setVolume;
  final void Function() onFullScreenTap;

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = audio?.path != null || isOnline;

    final children = [
      Row(
        children: [
          IconButton(
            icon: Icon(
              YaruIcons.shuffle,
              color: !active
                  ? theme.disabledColor
                  : (shuffle
                      ? theme.primaryColor
                      : theme.colorScheme.onSurface),
            ),
            onPressed: !active ? null : () => setShuffle(!(shuffle)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              onPressed: !active ? null : () => playPrevious(),
              icon: const Icon(YaruIcons.skip_backward),
            ),
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
              isPlaying ? YaruIcons.media_pause : YaruIcons.media_play,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              onPressed: !active ? null : () => playNext(),
              icon: const Icon(YaruIcons.skip_forward),
            ),
          ),
          IconButton(
            icon: Icon(
              YaruIcons.repeat_single,
              color: !active
                  ? theme.disabledColor
                  : (repeatSingle
                      ? theme.primaryColor
                      : theme.colorScheme.onSurface),
            ),
            onPressed: !active ? null : () => setRepeatSingle(!(repeatSingle)),
          ),
        ],
      ),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
