import 'package:flutter/material.dart';

import '../../data.dart';
import '../common/icons.dart';

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
    this.color,
  });

  final Audio? audio;
  final bool liked;

  final bool isStarredStation;
  final void Function(String station) removeStarredStation;
  final void Function(String name, Set<Audio> stations) addStarredStation;

  final void Function(Audio audio, bool notify) removeLikedAudio;
  final void Function(Audio audio, bool notify) addLikedAudio;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (audio?.audioType == AudioType.podcast) {
      return const SizedBox.shrink();
    }

    Widget likeIcon;
    if (audio?.audioType == AudioType.radio) {
      likeIcon = Iconz().getAnimatedStar(
        isStarredStation,
      );
    } else {
      likeIcon = Iconz().getAnimatedHeartIcon(liked: liked);
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
      color: color,
    );
  }
}
