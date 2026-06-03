import 'package:flutter/material.dart';

class FlagTheme extends StatelessWidget {
  const FlagTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const fallbackFonts = ['Noto Color Emoji', 'NotoEmoji'];

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
          bodyLarge: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontFamilyFallback: fallbackFonts),
          bodyMedium: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontFamilyFallback: fallbackFonts),
          bodySmall: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontFamilyFallback: fallbackFonts),
          titleLarge: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontFamilyFallback: fallbackFonts),
          titleMedium: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontFamilyFallback: fallbackFonts),
          titleSmall: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontFamilyFallback: fallbackFonts),
        ),
      ),
      child: child,
    );
  }
}
