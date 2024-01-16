import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../theme_data_x.dart';

const darkDividerColor = Color.fromARGB(19, 255, 255, 255);

ThemeData m3Theme({
  Brightness brightness = Brightness.light,
  Color color = Colors.greenAccent,
}) {
  final dividerColor = brightness == Brightness.light
      ? const Color.fromARGB(48, 0, 0, 0)
      : darkDividerColor;
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
    snackBarTheme: _createSnackBarThemeData(colorScheme),
  );
}

SnackBarThemeData _createSnackBarThemeData(ColorScheme scheme) {
  return const SnackBarThemeData(behavior: SnackBarBehavior.floating);
}

Color? getSideBarColor(ThemeData theme) => theme.scaffoldBackgroundColor;

Color getSnackBarTextColor(ThemeData theme) => yaruStyled
    ? Colors.white.withOpacity(0.7)
    : theme.colorScheme.onInverseSurface;

Color getPlayerBg(Color? surfaceTintColor, Color fallbackColor) {
  if (surfaceTintColor != null) {
    return (Platform.isLinux
        ? surfaceTintColor.withOpacity(0.05)
        : Color.alphaBlend(
            surfaceTintColor.withOpacity(0.2),
            fallbackColor,
          ));
  } else {
    return fallbackColor;
  }
}

bool get yaruStyled => Platform.isLinux;

bool get appleStyled => Platform.isMacOS || Platform.isIOS;

PopupMenuThemeData _createPopupMenuTheme(ColorScheme colorScheme) {
  final bgColor =
      colorScheme.isLight ? colorScheme.surface : colorScheme.surfaceVariant;
  return PopupMenuThemeData(
    color: bgColor,
    surfaceTintColor: bgColor,
    shape: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: colorScheme.onSurface.withOpacity(
          colorScheme.isLight ? 0.3 : 0.2,
        ),
        width: 1,
      ),
    ),
  );
}

MenuStyle _createMenuStyle(ColorScheme colorScheme) {
  final bgColor =
      colorScheme.isLight ? colorScheme.surface : colorScheme.surfaceVariant;

  return MenuStyle(
    surfaceTintColor: MaterialStateColor.resolveWith((states) => bgColor),
    shape: MaterialStateProperty.resolveWith(
      (states) => RoundedRectangleBorder(
        side: BorderSide(
          color: colorScheme.onSurface.withOpacity(
            colorScheme.isLight ? 0.3 : 0.2,
          ),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    side: MaterialStateBorderSide.resolveWith(
      (states) => BorderSide(
        color: colorScheme.onSurface.withOpacity(
          colorScheme.isLight ? 0.3 : 0.2,
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

const alphabetColors = {
  'A': Colors.red,
  'B': Colors.orange,
  'C': Colors.yellow,
  'D': Colors.green,
  'E': Colors.teal,
  'F': Colors.blue,
  'G': Colors.indigo,
  'H': Colors.purple,
  'I': Colors.pink,
  'J': Colors.deepOrange,
  'K': Colors.deepPurple,
  'L': Colors.cyan,
  'M': Colors.lightGreen,
  'N': Colors.lime,
  'O': Colors.amber,
  'P': Colors.brown,
  'Q': Colors.blueAccent,
  'R': Colors.blueGrey,
  'S': Colors.lightGreenAccent,
  'T': Colors.greenAccent,
  'U': Colors.pinkAccent,
  'V': Colors.purpleAccent,
  'W': Colors.amberAccent,
  'X': Colors.indigoAccent,
  'Y': Colors.cyanAccent,
  'Z': Colors.deepOrangeAccent,
};

Color getAlphabetColor(String text, [Color fallBackColor = Colors.black]) {
  final letter = text.isEmpty ? null : text[0];
  return alphabetColors[letter?.toUpperCase()] ?? fallBackColor;
}

InputDecoration createMaterialDecoration(ColorScheme colorScheme) {
  final outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(100),
    borderSide: BorderSide(width: 2, color: colorScheme.primary),
  );
  return InputDecoration(
    filled: true,
    contentPadding:
        const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
    border: outlineInputBorder,
    errorBorder: outlineInputBorder,
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    disabledBorder: outlineInputBorder,
    focusedErrorBorder: outlineInputBorder,
  );
}

InputDecoration createYaruDecoration(bool isLight) {
  final radius = BorderRadius.circular(kYaruButtonRadius);

  final fill = isLight ? const Color(0xffdcdcdc) : const Color(0xff2f2f2f);

  const textStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  return InputDecoration(
    filled: true,
    fillColor: fill,
    hoverColor: (fill).scale(lightness: 0.1),
    suffixIconConstraints:
        const BoxConstraints(maxWidth: kYaruTitleBarItemHeight),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: radius,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: radius,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: radius,
    ),
    isDense: true,
    contentPadding: const EdgeInsets.only(
      bottom: 10,
      top: 10,
      right: 15,
      left: 15,
    ),
    helperStyle: textStyle,
    hintStyle: textStyle,
    labelStyle: textStyle,
  );
}

ButtonStyle createPopupStyle(ThemeData themeData) {
  return TextButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
  );
}

Color? chipThemeColor(ThemeData theme) {
  return theme.colorScheme.onSurface.withOpacity(theme.isLight ? 0.1 : 0.03);
}
