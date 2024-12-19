import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../data/audio.dart';
import 'icons.dart';
import 'theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';

class AudioFallBackIcon extends StatelessWidget {
  const AudioFallBackIcon({
    super.key,
    required this.audio,
    this.iconSize,
    this.dimension,
    this.color,
  });

  final double? iconSize;
  final Audio? audio;
  final double? dimension;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final light = theme.isLight;
    final fallBackColor = theme.primaryColor;
    final gradientColor = color ??
        getAlphabetColor(
          audio?.title ?? audio?.album ?? '',
          fallBackColor,
        );
    return Container(
      height: dimension ?? double.infinity,
      width: dimension ?? double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            gradientColor.scale(lightness: light ? 0 : -0.4, saturation: -0.5),
            gradientColor.scale(
              lightness: light ? -0.1 : -0.2,
              saturation: -0.5,
            ),
          ],
        ),
      ),
      child: Icon(
        audio?.audioType?.iconData ?? Iconz.musicNote,
        size: iconSize,
        color: contrastColor(gradientColor).withOpacity(0.7),
      ),
    );
  }
}
