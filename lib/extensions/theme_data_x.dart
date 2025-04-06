import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';

extension ThemeDataX on ThemeData {
  bool get isLight => brightness == Brightness.light;
  Color get contrastyPrimary =>
      colorScheme.primary.scale(lightness: isLight ? -0.3 : 0.3);

  TextStyle? get pageHeaderStyle => textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        leadingDistribution: TextLeadingDistribution.proportional,
        fontSize: 25,
        color: colorScheme.onSurface.withValues(alpha: 0.9),
      );

  TextStyle? get pageHeaderDescription =>
      textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500);

  TextStyle? get pageHeaderSubtitleStyle =>
      textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500);

  Color get containerBg => colorScheme.surface.scale(
        lightness: isLight
            ? (AppConfig.yaruStyled ? -0.03 : -0.02)
            : (AppConfig.yaruStyled ? 0.01 : 0.02),
        saturation: -0.5,
      );
}
