import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../settings/settings_model.dart';
import 'icons.dart';

class AnimatedStar extends StatelessWidget with WatchItMixin {
  const AnimatedStar({
    super.key,
    required this.isStarred,
    this.color,
  });

  final bool isStarred;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final useYaruTheme =
        watchPropertyValue((SettingsModel m) => m.useYaruTheme);
    final iconSize = context.theme.iconTheme.size ?? 24.0;
    if (useYaruTheme) {
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

class AnimatedHeart extends StatelessWidget with WatchItMixin {
  const AnimatedHeart({
    super.key,
    required this.liked,
    this.color,
  });

  final bool liked;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final useYaruTheme =
        watchPropertyValue((SettingsModel m) => m.useYaruTheme);
    if (useYaruTheme) {
      return YaruAnimatedVectorIcon(
        liked ? YaruAnimatedIcons.heart_filled : YaruAnimatedIcons.heart,
        initialProgress: 1.0,
        color: color,
        size: context.theme.iconTheme.size ?? 24.0,
      );
    } else {
      return Icon(
        liked ? Icons.favorite : Icons.favorite_outline,
        color: color,
      );
    }
  }
}
