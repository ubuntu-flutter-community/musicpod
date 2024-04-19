import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../data.dart';
import '../../../theme.dart';
import '../../../theme_data_x.dart';

class RadioFallBackIcon extends StatelessWidget {
  const RadioFallBackIcon({
    super.key,
    this.iconSize,
    required this.station,
  });

  final double? iconSize;
  final Audio? station;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final light = theme.isLight;
    final fallBackColor = theme.cardColor;
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            getAlphabetColor(
              station?.title ?? station?.album ?? '',
              fallBackColor,
            ).scale(lightness: light ? 0 : -0.4, saturation: -0.5),
            getAlphabetColor(
              station?.title ?? station?.album ?? '',
              fallBackColor,
            ).scale(lightness: light ? -0.1 : -0.2, saturation: -0.5),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Icon(
          Iconz().radio,
          size: iconSize ?? 70,
          color: contrastColor(
            getAlphabetColor(
              station?.title ?? station?.album ?? '',
              fallBackColor,
            ),
          ).withOpacity(0.7),
        ),
      ),
    );
  }
}
