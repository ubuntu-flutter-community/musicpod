import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../constants.dart';
import '../../extensions/theme_data_x.dart';
import 'icons.dart';

ThemeData? yaruDarkWithTweaks(YaruThemeData yaru) {
  return yaru.darkTheme?.copyWith(
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) => Icon(Iconz().goBack),
    ),
    scaffoldBackgroundColor: yaru.darkTheme?.scaffoldBackgroundColor.scale(
      lightness: -0.35,
    ),
    dividerColor: yaruFixDarkDividerColor,
    dividerTheme: const DividerThemeData(
      color: yaruFixDarkDividerColor,
      space: 1.0,
      thickness: 0.0,
    ),
    cardColor: yaru.darkTheme?.cardColor.scale(
      lightness: -0.2,
    ),
    iconButtonTheme: iconButtonTheme(yaru.darkTheme),
  );
}

ThemeData? yaruLightWithTweaks(YaruThemeData yaru) {
  return yaru.theme?.copyWith(
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) => Icon(Iconz().goBack),
    ),
    cardColor: yaru.theme?.dividerColor.scale(
      lightness: -0.01,
    ),
    iconButtonTheme: iconButtonTheme(yaru.theme),
  );
}

IconButtonThemeData iconButtonTheme(ThemeData? data) {
  return IconButtonThemeData(
    style: data?.iconButtonTheme.style?.copyWith(
      iconSize: const WidgetStatePropertyAll(kYaruIconSize),
      iconColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled)
            ? data.disabledColor
            : data.colorScheme.onSurface,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? data.colorScheme.onSurface.withOpacity(0.1)
            : Colors.transparent,
      ),
    ),
  );
}

const yaruFixDarkDividerColor = Color.fromARGB(19, 255, 255, 255);

Color getPlayerBg(Color? surfaceTintColor, Color fallbackColor) {
  if (surfaceTintColor != null) {
    return Color.alphaBlend(
      surfaceTintColor.withOpacity(0.15),
      fallbackColor,
    );
  } else {
    return fallbackColor;
  }
}

bool get yaruStyled => Platform.isLinux;

bool get appleStyled => Platform.isMacOS || Platform.isIOS;

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

InputDecoration createMaterialDecoration({
  required ColorScheme colorScheme,
  TextStyle? style,
  bool isDense = false,
  bool filled = true,
  OutlineInputBorder? border,
  Color? fillColor,
  EdgeInsets? contentPadding,
  String? hintText,
  Widget? suffixIcon,
}) {
  final outlineInputBorder = border ??
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide(width: 1, color: colorScheme.outline),
      );
  return InputDecoration(
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(
      maxWidth: 200,
      maxHeight: kYaruTitleBarItemHeight,
    ),
    hintText: hintText,
    fillColor: fillColor,
    filled: filled,
    contentPadding: contentPadding ??
        const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
    border: outlineInputBorder,
    errorBorder: outlineInputBorder,
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder.copyWith(
      borderSide: BorderSide(
        width: 1,
        color: colorScheme.primary,
      ),
    ),
    disabledBorder: outlineInputBorder,
    focusedErrorBorder: outlineInputBorder,
    helperStyle: style,
    hintStyle: style,
    labelStyle: style,
    isDense: isDense,
  );
}

InputDecoration createYaruDecoration({
  required ThemeData theme,
  TextStyle? style,
  Color? fillColor,
  EdgeInsets? contentPadding,
  String? hintText,
  OutlineInputBorder? border,
  Widget? suffixIcon,
}) {
  final fill = theme.inputDecorationTheme.fillColor;

  final textStyle = style ??
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  return InputDecoration(
    suffixIcon: Center(
      widthFactor: 1,
      child: suffixIcon,
    ),
    hintText: hintText,
    filled: true,
    fillColor: fillColor ?? fill,
    hoverColor: (fillColor ?? fill)?.scale(lightness: 0.1),
    border: border,
    errorBorder: border,
    enabledBorder: border,
    focusedBorder: border,
    disabledBorder: border,
    focusedErrorBorder: border,
    isDense: true,
    contentPadding: contentPadding ??
        const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10.5,
        ),
    helperStyle: textStyle,
    hintStyle: textStyle,
    labelStyle: textStyle,
  );
}

Color? chipColor(ThemeData theme) {
  return yaruStyled
      ? theme.colorScheme.outline.withOpacity(theme.isLight ? 1 : 0.4)
      : null;
}

Color? chipBorder(ThemeData theme, bool loading) {
  return yaruStyled ? (loading ? null : Colors.transparent) : null;
}

Color? chipSelectionColor(ThemeData theme, bool loading) {
  return yaruStyled ? (loading ? theme.colorScheme.outline : null) : null;
}

double get likeButtonWidth => yaruStyled ? 62 : 70;

double get progressStrokeWidth => 3.0;

double get avatarIconRadius => (yaruStyled ? kYaruTitleBarItemHeight : 38) / 2;

double get bigPlayButtonRadius => yaruStyled ? 22 : 23;

EdgeInsets get bigPlayButtonPadding =>
    EdgeInsets.symmetric(horizontal: yaruStyled ? 2.5 : 5);

FontWeight get smallTextFontWeight =>
    yaruStyled ? FontWeight.w100 : FontWeight.w400;

FontWeight get mediumTextWeight =>
    yaruStyled ? FontWeight.w400 : FontWeight.w400;

FontWeight get largeTextWeight =>
    yaruStyled ? FontWeight.w200 : FontWeight.w300;

double get chipHeight => isMobile ? 40 : 36.0;

EdgeInsets get audioTilePadding =>
    isMobile ? kMobileAudioTilePadding : kDesktopAudioTilePadding;

SliverGridDelegate get audioCardGridDelegate =>
    isMobile ? kMobileAudioCardGridDelegate : kAudioCardGridDelegate;

EdgeInsetsGeometry get appBarSingleActionSpacing => Platform.isMacOS
    ? const EdgeInsets.only(right: 5, left: 5)
    : const EdgeInsets.only(right: 10, left: 20);

EdgeInsetsGeometry get radioHistoryListPadding =>
    EdgeInsets.only(left: yaruStyled ? 0 : 5);

EdgeInsets get countryPillPadding => yaruStyled
    ? const EdgeInsets.only(
        bottom: 9,
        top: 9,
        right: 15,
        left: 15,
      )
    : const EdgeInsets.only(top: 11, bottom: 11, left: 15, right: 15);

double get inputHeight => isMobile
    ? 40
    : yaruStyled
        ? kYaruTitleBarItemHeight
        : 36;

double get audioCardDimension => kAudioCardDimension - (isMobile ? 15 : 0);

double get bottomPlayerHeight => isMobile ? 80.0 : 90.0;

List<Widget> space({double gap = 5, required Iterable<Widget> children}) =>
    children
        .expand(
          (item) sync* {
            yield SizedBox(width: gap);
            yield item;
          },
        )
        .skip(1)
        .toList();
