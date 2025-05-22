import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';

class PlayerFallBackImage extends StatelessWidget {
  const PlayerFallBackImage({
    super.key,
    this.audioType,
    required this.height,
    required this.width,
    this.noIcon = false,
  });

  final AudioType? audioType;
  final double height;
  final double width;
  final bool noIcon;

  @override
  Widget build(BuildContext context) {
    final iconSize = width * 0.7;
    final theme = context.theme;
    final color = theme.cardColor.scale(lightness: theme.isLight ? -0.15 : 0.3);
    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              color.scale(
                lightness: theme.isLight ? 0 : -0.4,
                saturation: -0.5,
              ),
              color.scale(
                lightness: theme.isLight ? -0.1 : -0.2,
                saturation: -0.5,
              ),
            ],
          ),
        ),
        width: width,
        height: height,
        child: noIcon
            ? null
            : Icon(
                audioType?.iconData ?? Iconz.musicNote,
                size: iconSize,
                color: contrastColor(color),
              ),
      ),
    );
  }
}
