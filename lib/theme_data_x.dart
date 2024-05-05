import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

extension ThemeDataX on ThemeData {
  bool get isLight => brightness == Brightness.light;
  Color get contrastyPrimary =>
      colorScheme.primary.scale(lightness: isLight ? -0.3 : 0.3);

  TextStyle? get pageHeaderStyle => textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
        leadingDistribution: TextLeadingDistribution.proportional,
        fontSize: 30,
        color: colorScheme.onSurface.withOpacity(0.9),
      );
}
