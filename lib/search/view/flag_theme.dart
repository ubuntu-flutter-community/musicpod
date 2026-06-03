import 'package:flutter/material.dart';

class FlagTheme extends StatelessWidget {
  const FlagTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const fallbackFonts = ['Noto Color Emoji', 'NotoEmoji'];

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Theme(
      data: theme.copyWith(
        textTheme: textTheme.copyWith(
          bodyLarge: textTheme.bodyLarge?.copyWith(
            fontFamilyFallback: fallbackFonts,
          ),
          bodyMedium: textTheme.bodyMedium?.copyWith(
            fontFamilyFallback: fallbackFonts,
          ),
          bodySmall: textTheme.bodySmall?.copyWith(
            fontFamilyFallback: fallbackFonts,
          ),
          titleLarge: textTheme.titleLarge?.copyWith(
            fontFamilyFallback: fallbackFonts,
          ),
          titleMedium: textTheme.titleMedium?.copyWith(
            fontFamilyFallback: fallbackFonts,
          ),
          titleSmall: textTheme.titleSmall?.copyWith(
            fontFamilyFallback: fallbackFonts,
          ),
        ),
      ),
      child: child,
    );
  }
}
