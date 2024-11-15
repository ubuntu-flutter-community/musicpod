import 'icons.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'theme.dart';

class AnimatedStar extends StatelessWidget {
  const AnimatedStar({
    super.key,
    required this.isStarred,
    this.color,
  });

  final bool isStarred;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (yaruStyled) {
      return YaruAnimatedVectorIcon(
        isStarred ? YaruAnimatedIcons.star_filled : YaruAnimatedIcons.star,
        initialProgress: 1.0,
        color: color,
        size: iconSize,
      );
    } else {
      return isStarred
          ? Icon(
              Iconz.starFilled,
              size: iconSize,
              color: color,
            )
          : Icon(
              Iconz.star,
              size: iconSize,
              color: color,
            );
    }
  }
}

class AnimatedHeart extends StatelessWidget {
  const AnimatedHeart({
    super.key,
    required this.liked,
    this.color,
  });

  final bool liked;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (yaruStyled) {
      return YaruAnimatedVectorIcon(
        liked ? YaruAnimatedIcons.heart_filled : YaruAnimatedIcons.heart,
        initialProgress: 1.0,
        color: color,
        size: iconSize,
      );
    } else {
      return Icon(
        liked ? Icons.favorite : Icons.favorite_outline,
        color: color,
      );
    }
  }
}
