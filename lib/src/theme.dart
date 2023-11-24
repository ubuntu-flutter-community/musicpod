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

Color? getSideBarColor(ThemeData theme) =>
    yaruStyled ? null : theme.scaffoldBackgroundColor;

Color getSnackBarTextColor(ThemeData theme) => yaruStyled
    ? Colors.white.withOpacity(0.7)
    : theme.colorScheme.onInverseSurface;

Color getPlayerBg(Color? surfaceTintColor, Color scaffoldBg) {
  if (surfaceTintColor != null) {
    return (Platform.isLinux
        ? surfaceTintColor.withOpacity(0.05)
        : Color.alphaBlend(
            surfaceTintColor.withOpacity(0.2),
            scaffoldBg,
          ));
  } else {
    return scaffoldBg;
  }
}

bool get yaruStyled => Platform.isLinux;

bool get appleStyled => Platform.isMacOS || Platform.isIOS;
