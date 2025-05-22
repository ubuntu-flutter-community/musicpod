import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import 'icons.dart';

class AnimatedStar extends StatelessWidget {
  const AnimatedStar({super.key, required this.isStarred, this.color});

  final bool isStarred;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconSize = context.theme.iconTheme.size ?? 24.0;
    if (Iconz.yaru) {
      return YaruAnimatedVectorIcon(
        isStarred ? YaruAnimatedIcons.star_filled : YaruAnimatedIcons.star,
        initialProgress: 1.0,
        color: color,
        size: iconSize,
      );
    }
    return Icon(
      isStarred ? Iconz.starFilled : Iconz.star,
      size: iconSize,
      color: color,
    );
  }
}

class AnimatedHeart extends StatelessWidget {
  const AnimatedHeart({super.key, required this.liked, this.color});

  final bool liked;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconSize = context.theme.iconTheme.size ?? 24.0;

    if (Iconz.yaru) {
      return YaruAnimatedVectorIcon(
        liked ? YaruAnimatedIcons.heart_filled : YaruAnimatedIcons.heart,
        initialProgress: 1.0,
        color: color,
        size: iconSize,
      );
    }
    return Icon(
      liked ? Iconz.heartFilled : Iconz.heart,
      color: color,
      size: iconSize,
    );
  }
}
