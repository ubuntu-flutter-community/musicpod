import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../data.dart';

class LikeIconButton extends StatelessWidget {
  const LikeIconButton({
    super.key,
    required this.audio,
    required this.liked,
    required this.isStarredStation,
    required this.removeStarredStation,
    required this.addStarredStation,
    required this.removeLikedAudio,
    required this.addLikedAudio,
  });

  final Audio? audio;
  final bool liked;

  final bool isStarredStation;
  final void Function(String station) removeStarredStation;
  final void Function(String name, Set<Audio> stations) addStarredStation;

  final void Function(Audio audio, bool notify) removeLikedAudio;
  final void Function(Audio audio, bool notify) addLikedAudio;

  @override
  Widget build(BuildContext context) {
    Widget likeIcon;
    if (audio?.audioType == AudioType.radio) {
      likeIcon = YaruAnimatedIcon(
        isStarredStation
            ? const YaruAnimatedStarIcon(filled: true)
            : const YaruAnimatedStarIcon(filled: false),
        initialProgress: 1.0,
        size: kYaruIconSize,
      );
    } else {
      likeIcon = YaruAnimatedIcon(
        liked
            ? const YaruAnimatedHeartIcon(filled: true)
            : const YaruAnimatedHeartIcon(filled: false),
        initialProgress: 1.0,
        size: kYaruIconSize,
      );
    }

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
    return IconButton(
      icon: likeIcon,
      onPressed: onLike,
    );
  }
}
