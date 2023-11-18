import 'dart:io';

import 'package:flutter/material.dart';

ThemeData m3Theme({
  Brightness brightness = Brightness.light,
  Color color = Colors.greenAccent,
}) {
  final dividerColor = brightness == Brightness.light
      ? const Color.fromARGB(48, 0, 0, 0)
      : const Color.fromARGB(18, 255, 255, 255);
  return ThemeData(
    useMaterial3: true,
    dividerColor: dividerColor,
    dividerTheme: DividerThemeData(
      color: dividerColor,
      space: 1.0,
      thickness: 0.0,
    ),
    colorScheme: ColorScheme.fromSeed(
      surfaceTint: Colors.transparent,
      seedColor: color,
      brightness: brightness,
    ),
    splashFactory:
        Platform.isMacOS || Platform.isIOS ? NoSplash.splashFactory : null,
  );
}
