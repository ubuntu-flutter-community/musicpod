import 'package:flutter/material.dart';
import 'package:musicpod/data/audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({
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
  });

  final Audio? audio;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final void Function()? onLike;
    if (audio == null) {
      onLike = null;
    } else {
      if (audio?.audioType == AudioType.radio) {
        onLike = () {
          isStarredStation
              ? removeStarredStation(audio?.title ?? audio.toString())
              : addStarredStation(
                  audio?.title ?? audio.toString(),
                  {audio!},
                );
        };
      } else {
        onLike = () {
          liked ? removeLikedAudio(audio!, true) : addLikedAudio(audio!, true);
        };
      }
    }

    Icon likeIcon;
    if (audio?.audioType == AudioType.radio) {
      if (isStarredStation) {
        likeIcon = const Icon(YaruIcons.star_filled);
      } else {
        likeIcon = const Icon(YaruIcons.star);
      }
    } else {
      if (liked) {
        likeIcon = const Icon(YaruIcons.heart_filled);
      } else {
        likeIcon = const Icon(YaruIcons.heart);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        YaruIconButton(
          icon: likeIcon,
          onPressed: onLike,
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
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: YaruIconButton(
            onPressed: () => playPrevious(),
            icon: const Icon(YaruIcons.skip_backward),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: YaruIconButton(
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
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: YaruIconButton(
            onPressed: () => playNext(),
            icon: const Icon(YaruIcons.skip_forward),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: YaruIconButton(
            icon: Icon(
              YaruIcons.repeat_single,
              color: theme.colorScheme.onSurface,
            ),
            isSelected: repeatSingle == true,
            onPressed: () => setRepeatSingle(!(repeatSingle)),
          ),
        ),
        YaruIconButton(
          icon: Icon(
            YaruIcons.shuffle,
            color: theme.colorScheme.onSurface,
          ),
          isSelected: shuffle,
          onPressed: () => setShuffle(!(shuffle)),
        )
      ],
    );
  }
}
