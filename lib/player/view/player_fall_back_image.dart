import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';

class PlayerFallBackImage extends StatelessWidget {
  const PlayerFallBackImage({
    super.key,
    this.audio,
    required this.height,
    required this.width,
    this.noIcon = false,
  });

  final Audio? audio;
  final double height;
  final double width;
  final bool noIcon;

  @override
  Widget build(BuildContext context) {
    final iconSize = width * 0.7;
    final theme = context.theme;
    IconData iconData;
    if (audio?.audioType == AudioType.radio) {
      iconData = Iconz.radio;
    } else if (audio?.audioType == AudioType.podcast) {
      iconData = Iconz.podcast;
    } else {
      iconData = Iconz.musicNote;
    }
    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              getAlphabetColor(
                audio?.title ?? audio?.album ?? 'a',
              ).scale(
                lightness: theme.isLight ? 0 : -0.4,
                saturation: -0.5,
              ),
              getAlphabetColor(
                audio?.title ?? audio?.album ?? 'a',
              ).scale(
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
                iconData,
                size: iconSize,
                color: contrastColor(
                  getAlphabetColor(
                    audio?.title ?? audio?.album ?? 'a',
                  ),
                ),
              ),
      ),
    );
  }
}
