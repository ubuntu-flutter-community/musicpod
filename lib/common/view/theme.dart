import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import 'icons.dart';
import 'ui_constants.dart';

ThemeData? yaruDarkWithTweaks(YaruThemeData yaru) {
  return yaru.darkTheme?.copyWith(
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) => Icon(Iconz.goBack),
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
      backButtonIconBuilder: (context) => Icon(Iconz.goBack),
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
            ? data.colorScheme.onSurface.withValues(alpha: 0.1)
            : Colors.transparent,
      ),
    ),
  );
}

const yaruFixDarkDividerColor = Color.fromARGB(19, 255, 255, 255);

Color getPlayerBg(Color? surfaceTintColor, Color fallbackColor) {
  if (surfaceTintColor != null) {
    return Color.alphaBlend(
      surfaceTintColor.withValues(alpha: 0.15),
      fallbackColor,
    );
  } else {
    return fallbackColor;
  }
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

double get searchBarWidth =>
    isMobilePlatform ? kMobileSearchBarWidth : kDesktopSearchBarWidth;

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
  Widget? prefixIcon,
}) {
  final outlineInputBorder = border ??
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide(
          width: isMobilePlatform ? 2 : 1,
          color: colorScheme.outline,
        ),
      );
  return InputDecoration(
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    suffixIconConstraints: BoxConstraints(
      maxHeight: isMobilePlatform ? kToolbarHeight : kYaruTitleBarItemHeight,
    ),
    hintText: hintText,
    fillColor: fillColor,
    filled: filled,
    contentPadding: isMobilePlatform
        ? const EdgeInsets.only(top: 16, bottom: 0, left: 15, right: 15)
        : contentPadding ??
            const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
    border: outlineInputBorder,
    errorBorder: outlineInputBorder,
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder.copyWith(
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: isMobilePlatform ? 2 : 1,
      ),
    ),
    disabledBorder: outlineInputBorder,
    focusedErrorBorder: outlineInputBorder,
    helperStyle: isMobilePlatform ? null : style,
    hintStyle: isMobilePlatform ? null : style,
    labelStyle: isMobilePlatform ? null : style,
    isDense: isMobilePlatform ? false : isDense,
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
  Widget? prefixIcon,
}) {
  final fill = theme.inputDecorationTheme.fillColor;

  final textStyle = style ??
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  return InputDecoration(
    prefixIcon: prefixIcon,
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

double get iconSize => yaruStyled
    ? kYaruIconSize
    : isMobilePlatform
        ? 24.0
        : kLargestSpace;

double get sideBarImageSize => 38;

double get likeButtonWidth => yaruStyled ? 62 : 70;

double get progressStrokeWidth => 3.0;

double get smallAvatarButtonRadius =>
    (yaruStyled
        ? kYaruTitleBarItemHeight
        : isMobilePlatform
            ? 42
            : 38) /
    2;

double get bigAvatarButtonRadius => yaruStyled
    ? 22
    : isMobilePlatform
        ? 26
        : 23;

EdgeInsets get filterPanelPadding =>
    EdgeInsets.only(top: isMobilePlatform ? 10 : 0, bottom: 10);

EdgeInsets get bigPlayButtonPadding =>
    EdgeInsets.symmetric(horizontal: yaruStyled ? 2.5 : 5);

FontWeight get smallTextFontWeight =>
    yaruStyled ? FontWeight.w100 : FontWeight.w400;

FontWeight get mediumTextWeight =>
    yaruStyled ? FontWeight.w400 : FontWeight.w400;

FontWeight get largeTextWeight =>
    yaruStyled ? FontWeight.w200 : FontWeight.w300;

double get chipHeight => isMobilePlatform ? 40 : 34.0;

EdgeInsets get audioTilePadding => kAudioTilePadding;

SliverGridDelegate get audioCardGridDelegate =>
    isMobilePlatform ? kMobileAudioCardGridDelegate : kAudioCardGridDelegate;

EdgeInsets get appBarSingleActionSpacing => Platform.isMacOS
    ? const EdgeInsets.only(right: 5, left: 5)
    : EdgeInsets.only(right: 10, left: isMobilePlatform ? 0 : kLargestSpace);

EdgeInsetsGeometry get radioHistoryListPadding =>
    EdgeInsets.only(left: yaruStyled ? 0 : 5);

EdgeInsets get mainPageIconPadding =>
    yaruStyled || appleStyled ? kMainPageIconPadding : EdgeInsets.zero;

EdgeInsets get countryPillPadding => yaruStyled
    ? const EdgeInsets.only(
        bottom: 9,
        top: 9,
        right: 15,
        left: 15,
      )
    : const EdgeInsets.only(top: 11, bottom: 11, left: 15, right: 15);

double get inputHeight => isMobilePlatform
    ? 40
    : yaruStyled
        ? kYaruTitleBarItemHeight
        : 36;

double get audioCardDimension =>
    kAudioCardDimension - (isMobilePlatform ? 15 : 0);

double get bottomPlayerDefaultHeight => isMobilePlatform ? 76.0 : 90.0;

double get navigationBarHeight => bottomPlayerDefaultHeight;

double? get bottomPlayerPageGap => isMobilePlatform
    ? bottomPlayerDefaultHeight + navigationBarHeight + kLargestSpace
    : null;

EdgeInsets get playerTopControlsPadding => EdgeInsets.only(
      right: kLargestSpace,
      top: Platform.isMacOS
          ? 0
          : isMobilePlatform
              ? 2 * kLargestSpace
              : kLargestSpace,
    );

NavigationBarThemeData navigationBarTheme({required ThemeData theme}) =>
    theme.navigationBarTheme.copyWith(
      iconTheme: WidgetStatePropertyAll(
        theme.iconTheme.copyWith(
          size: 18,
          applyTextScaling: true,
        ),
      ),
    );

List<Widget> space({
  double widthGap = kSmallestSpace,
  double heightGap = kSmallestSpace,
  required Iterable<Widget> children,
  bool expandAll = false,
}) =>
    children
        .expand(
          (item) sync* {
            yield SizedBox(
              width: widthGap,
              height: heightGap,
            );
            if (expandAll) {
              yield Expanded(child: item);
            } else {
              yield item;
            }
          },
        )
        .skip(1)
        .toList();
