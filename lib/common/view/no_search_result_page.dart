import 'package:flutter/material.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import 'ui_constants.dart';

class NoSearchResultPage extends StatelessWidget {
  const NoSearchResultPage({super.key, this.message, this.icon});

  final Widget? message;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final style = theme.textTheme.headlineSmall?.copyWith(
      color: theme.colorScheme.onSurface,
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 50, right: 50, bottom: 50),
        child: SizedBox(
          width: 500,
          child: DefaultTextStyle(
            style:
                style ??
                TextStyle(
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                message ??
                    Text(
                      context.l10n.nothingFound,
                      style: style,
                      textAlign: TextAlign.center,
                    ),
                const SizedBox(height: kLargestSpace),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SliverNoSearchResultPage extends StatelessWidget {
  const SliverNoSearchResultPage({
    super.key,
    this.message,
    this.icon,
    this.expand = true,
  });

  final Widget? message;
  final Widget? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    if (expand) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: NoSearchResultPage(icon: icon, message: message),
      );
    }

    return SliverToBoxAdapter(
      child: NoSearchResultPage(icon: icon, message: message),
    );
  }
}
