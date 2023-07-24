import 'package:flutter/material.dart';
import 'package:musicpod/data/audio.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final children = [
      Row(
        children: [
          YaruIconButton(
            icon: Icon(
              YaruIcons.shuffle,
              color: theme.colorScheme.onSurface,
            ),
            isSelected: shuffle,
            onPressed: () => setShuffle(!(shuffle)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: YaruIconButton(
              onPressed: () => playPrevious(),
              icon: const Icon(YaruIcons.skip_backward),
            ),
          ),
          YaruIconButton(
            onPressed: audio == null
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
            child: YaruIconButton(
              onPressed: () => playNext(),
              icon: const Icon(YaruIcons.skip_forward),
            ),
          ),
          YaruIconButton(
            icon: Icon(
              YaruIcons.repeat_single,
              color: theme.colorScheme.onSurface,
            ),
            isSelected: repeatSingle == true,
            onPressed: () => setRepeatSingle(!(repeatSingle)),
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
