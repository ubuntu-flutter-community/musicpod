import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import 'theme.dart';

class NoSearchResultPage extends StatelessWidget {
  const NoSearchResultPage({super.key, this.message, this.icon});

  final Widget? message;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final style = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: largeTextWeight,
      color: theme.colorScheme.onSurface,
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 50,
          right: 50,
          bottom: 50,
        ),
        child: SizedBox(
          width: 500,
          child: DefaultTextStyle(
            style: style ??
                TextStyle(
                  fontWeight: largeTextWeight,
                  color: theme.colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon ?? const AnimatedEmoji(AnimatedEmojis.thinkingFace),
                const SizedBox(
                  height: 10,
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
      ),
    );
  }
}

class SliverFillNoSearchResultPage extends StatelessWidget {
  const SliverFillNoSearchResultPage({super.key, this.message, this.icon});

  final Widget? message;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: NoSearchResultPage(
        icon: icon,
        message: message,
      ),
    );
  }
}
