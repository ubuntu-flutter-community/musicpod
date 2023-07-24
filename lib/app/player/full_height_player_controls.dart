import 'package:flutter/material.dart';
import 'package:musicpod/app/player/like_icon_button.dart';
import 'package:musicpod/app/player/queue_popup.dart';
import 'package:musicpod/app/player/volume_popup.dart';
import 'package:musicpod/data/audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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

  final bool isStarredStation;
  final void Function(String station) removeStarredStation;
  final void Function(String name, Set<Audio> stations) addStarredStation;

  final void Function(Audio audio, bool notify) removeLikedAudio;
  final void Function(Audio audio, bool notify) addLikedAudio;
  final double volume;
  final Future<void> Function(double value) setVolume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const spacing = 7.0;

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
        const SizedBox(
          width: spacing,
        ),
        YaruIconButton(
          onPressed: audio?.website == null
              ? null
              : () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: TextButton(
                        child: Text(
                          'Copied to clipboard: ${audio?.website}',
                        ),
                        onPressed: () => launchUrl(Uri.parse(audio!.website!)),
                      ),
                    ),
                  ),
          icon: const Icon(YaruIcons.share),
        ),
        const SizedBox(
          width: spacing,
        ),
        YaruIconButton(
          icon: Icon(
            YaruIcons.shuffle,
            color: theme.colorScheme.onSurface,
          ),
          isSelected: shuffle,
          onPressed: () => setShuffle(!(shuffle)),
        ),
        const SizedBox(
          width: spacing,
        ),
        YaruIconButton(
          onPressed: () => playPrevious(),
          icon: const Icon(YaruIcons.skip_backward),
        ),
        const SizedBox(
          width: spacing,
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
        const SizedBox(
          width: spacing,
        ),
        YaruIconButton(
          onPressed: () => playNext(),
          icon: const Icon(YaruIcons.skip_forward),
        ),
        const SizedBox(
          width: spacing,
        ),
        YaruIconButton(
          icon: Icon(
            YaruIcons.repeat_single,
            color: theme.colorScheme.onSurface,
          ),
          isSelected: repeatSingle == true,
          onPressed: () => setRepeatSingle(!(repeatSingle)),
        ),
        const SizedBox(
          width: spacing,
        ),
        VolumeSliderPopup(volume: volume, setVolume: setVolume),
        const SizedBox(
          width: spacing,
        ),
        QueuePopup(
          audio: audio,
          queue: queue,
        ),
      ],
    );
  }
}
