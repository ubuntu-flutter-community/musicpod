import 'dart:io';

import 'package:flutter/material.dart';

ThemeData m3Theme({
  Brightness brightness = Brightness.light,
  Color color = Colors.greenAccent,
}) {
  final dividerColor = brightness == Brightness.light
      ? const Color.fromARGB(48, 0, 0, 0)
      : const Color.fromARGB(18, 255, 255, 255);
  final colorScheme = ColorScheme.fromSeed(
    surfaceTint: Colors.transparent,
    seedColor: color,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    dividerColor: dividerColor,
    dividerTheme: DividerThemeData(
      color: dividerColor,
      space: 1.0,
      thickness: 0.0,
    ),
    menuTheme: _createMenuTheme(colorScheme),
    popupMenuTheme: _createPopupMenuTheme(colorScheme),
    dropdownMenuTheme: _createDropdownMenuTheme(colorScheme),
    colorScheme: colorScheme,
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

PopupMenuThemeData _createPopupMenuTheme(ColorScheme colorScheme) {
  final bgColor = colorScheme.brightness == Brightness.light
      ? colorScheme.surface
      : colorScheme.surfaceVariant;
  return PopupMenuThemeData(
    color: bgColor,
    surfaceTintColor: bgColor,
    shape: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: colorScheme.onSurface.withOpacity(
          colorScheme.brightness == Brightness.light ? 0.3 : 0.2,
        ),
        width: 1,
      ),
    ),
  );
}

MenuStyle _createMenuStyle(ColorScheme colorScheme) {
  final bgColor = colorScheme.brightness == Brightness.light
      ? colorScheme.surface
      : colorScheme.surfaceVariant;

  return MenuStyle(
    surfaceTintColor: MaterialStateColor.resolveWith((states) => bgColor),
    shape: MaterialStateProperty.resolveWith(
      (states) => RoundedRectangleBorder(
        side: BorderSide(
          color: colorScheme.onSurface.withOpacity(
            colorScheme.brightness == Brightness.light ? 0.3 : 0.2,
          ),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    side: MaterialStateBorderSide.resolveWith(
      (states) => BorderSide(
        color: colorScheme.onSurface.withOpacity(
          colorScheme.brightness == Brightness.light ? 0.3 : 0.2,
        ),
        width: 1,
      ),
    ),
    elevation: MaterialStateProperty.resolveWith((states) => 1),
    backgroundColor: MaterialStateProperty.resolveWith((states) => bgColor),
  );
}

MenuThemeData _createMenuTheme(ColorScheme colorScheme) {
  return MenuThemeData(
    style: _createMenuStyle(colorScheme),
  );
}

DropdownMenuThemeData _createDropdownMenuTheme(ColorScheme colorScheme) {
  return DropdownMenuThemeData(
    menuStyle: _createMenuStyle(colorScheme),
  );
}
