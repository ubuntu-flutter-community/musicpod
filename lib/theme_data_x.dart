import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

extension ThemeDataX on ThemeData {
  bool get isLight => brightness == Brightness.light;
  Color get contrastyPrimary =>
      colorScheme.primary.scale(lightness: isLight ? -0.3 : 0.3);
}
