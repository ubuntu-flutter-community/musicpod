import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';

import '../../common.dart';
import '../l10n/l10n.dart';

class NoSearchResultPage extends StatelessWidget {
  const NoSearchResultPage({
    super.key,
    this.message,
    this.icons,
  });

  final Widget? message;
  final Widget? icons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineSmall != null
        ? theme.textTheme.headlineSmall?.copyWith(
            fontWeight: largeTextWeight,
            color: theme.colorScheme.onSurface,
          )
        : TextStyle(
            fontWeight: largeTextWeight,
            color: theme.colorScheme.onSurface,
          );
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(50),
        child: DefaultTextStyle(
          style: style!,
          textAlign: TextAlign.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icons ?? const AnimatedEmoji(AnimatedEmojis.thinkingFace),
              const SizedBox(
                height: 20,
              ),
              message ??
                  Text(
                    context.l10n.nothingFound,
                    style: style,
                    textAlign: TextAlign.center,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
