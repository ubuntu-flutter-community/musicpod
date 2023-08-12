import 'package:flutter/material.dart';
import 'package:musicpod/l10n/l10n.dart';

class NoSearchResultPage extends StatelessWidget {
  const NoSearchResultPage({
    super.key,
    this.message,
  });

  final Widget? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineSmall != null
        ? theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w100,
            color: theme.colorScheme.onSurface,
          )
        : TextStyle(
            fontWeight: FontWeight.w100,
            color: theme.colorScheme.onSurface,
          );
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(50),
        child: DefaultTextStyle(
          style: style!,
          textAlign: TextAlign.center,
          child: message ??
              Text(
                context.l10n.nothingFound,
                style: style,
                textAlign: TextAlign.center,
              ),
        ),
      ),
    );
  }
}
