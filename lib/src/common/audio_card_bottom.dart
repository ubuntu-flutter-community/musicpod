import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../constants.dart';
import '../../theme_data_x.dart';

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
    final theme = context.t;
    final light = theme.isLight;

    return Tooltip(
      message: text ?? '',
      child: Container(
        width: kAudioCardDimension,
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
                  width: kAudioCardDimension - 20,
                  child: Shimmer.fromColors(
                    baseColor: theme.cardColor,
                    highlightColor: light
                        ? theme.cardColor.scale(lightness: -0.1)
                        : theme.cardColor.scale(lightness: 0.05),
                    child: Container(
                      color: theme.cardColor,
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
    );
  }
}
