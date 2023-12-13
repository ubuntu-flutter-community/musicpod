import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru/yaru.dart';

import '../../constants.dart';

class AudioCardBottom extends StatelessWidget {
  const AudioCardBottom({
    super.key,
    this.text,
    this.maxLines = 1,
    this.style,
  });

  final String? text;
  final int maxLines;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Tooltip(
        message: text ?? '',
        child: Container(
          width: kSmallCardHeight,
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 5,
          ),
          child: text == null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: SizedBox(
                    height: 15,
                    width: kSmallCardHeight - 20,
                    child: Shimmer.fromColors(
                      baseColor: light ? kCardColorLight : kCardColorDark,
                      highlightColor: light
                          ? kCardColorLight.scale(lightness: -0.1)
                          : kCardColorDark.scale(lightness: 0.05),
                      child: Container(
                        color: light ? kCardColorLight : kCardColorDark,
                      ),
                    ),
                  ),
                )
              : Text(
                  text ?? '',
                  style: style ??
                      theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.9),
                      ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: maxLines,
                ),
        ),
      ),
    );
  }
}
