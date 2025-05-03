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
    AppConfig.isMobilePlatform ? kMobileSearchBarWidth : kDesktopSearchBarWidth;

double get searchBarBorderRadius =>
    AppConfig.yaruStyled ? kYaruButtonRadius : 100;

Color? audioFilterBackgroundColor(ThemeData theme, bool selected) => selected
    ? AppConfig.yaruStyled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.15)
        : (theme.chipTheme.selectedColor ?? theme.colorScheme.primary)
    : null;

Color? audioFilterForegroundColor(ThemeData theme, bool selected) => selected
    ? theme.colorScheme.isDark
        ? Colors.white
        : Colors.black
    : theme.colorScheme.onSurface.scale(alpha: AppConfig.yaruStyled ? 1 : -0.3);

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
          width: AppConfig.isMobilePlatform ? 2 : 1,
          color: colorScheme.outline,
        ),
      );
  return InputDecoration(
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    suffixIconConstraints: BoxConstraints(
      maxHeight:
          AppConfig.isMobilePlatform ? kToolbarHeight : kYaruTitleBarItemHeight,
    ),
    hintText: hintText,
    fillColor: fillColor,
    filled: filled,
    contentPadding: AppConfig.isMobilePlatform
        ? const EdgeInsets.only(top: 16, bottom: 0, left: 15, right: 15)
        : contentPadding ??
            const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
    border: outlineInputBorder,
    errorBorder: outlineInputBorder,
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder.copyWith(
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: AppConfig.isMobilePlatform ? 2 : 1,
      ),
    ),
    disabledBorder: outlineInputBorder,
    focusedErrorBorder: outlineInputBorder,
    helperStyle: AppConfig.isMobilePlatform ? null : style,
    hintStyle: AppConfig.isMobilePlatform ? null : style,
    labelStyle: AppConfig.isMobilePlatform ? null : style,
    isDense: AppConfig.isMobilePlatform ? false : isDense,
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

double get iconSize => AppConfig.yaruStyled
    ? kYaruIconSize
    : AppConfig.isMobilePlatform
        ? 24.0
        : kLargestSpace;

double get sideBarImageSize => 38;

double get likeButtonWidth => AppConfig.yaruStyled ? 62 : 70;

double get progressStrokeWidth => 3.0;

double get smallAvatarButtonRadius =>
    (AppConfig.yaruStyled
        ? kYaruTitleBarItemHeight
        : AppConfig.isMobilePlatform
            ? 42
            : 38) /
    2;

double get bigAvatarButtonRadius => AppConfig.yaruStyled
    ? 22
    : AppConfig.isMobilePlatform
        ? 26
        : 23;

EdgeInsets get filterPanelPadding =>
    EdgeInsets.only(top: AppConfig.isMobilePlatform ? 10 : 0, bottom: 10);

EdgeInsets get bigPlayButtonPadding =>
    EdgeInsets.symmetric(horizontal: AppConfig.yaruStyled ? 2.5 : 5);

FontWeight get smallTextFontWeight =>
    AppConfig.yaruStyled ? FontWeight.w100 : FontWeight.w400;

FontWeight get mediumTextWeight =>
    AppConfig.yaruStyled ? FontWeight.w400 : FontWeight.w400;

FontWeight get largeTextWeight =>
    AppConfig.yaruStyled ? FontWeight.w200 : FontWeight.w300;

double get chipHeight => AppConfig.isMobilePlatform ? 40 : 34.0;

EdgeInsets get audioTilePadding => kAudioTilePadding;

SliverGridDelegate get audioCardGridDelegate => AppConfig.isMobilePlatform
    ? kMobileAudioCardGridDelegate
    : kAudioCardGridDelegate;

EdgeInsets get appBarSingleActionSpacing => Platform.isMacOS
    ? const EdgeInsets.only(right: 5, left: 5)
    : EdgeInsets.only(
        right: 10,
        left: AppConfig.isMobilePlatform ? 0 : kLargestSpace,
      );

EdgeInsetsGeometry get radioHistoryListPadding =>
    EdgeInsets.only(left: AppConfig.yaruStyled ? 0 : 5);

EdgeInsets get mainPageIconPadding =>
    AppConfig.yaruStyled || AppConfig.appleStyled
        ? kMainPageIconPadding
        : EdgeInsets.zero;

EdgeInsets get countryPillPadding => AppConfig.yaruStyled
    ? const EdgeInsets.only(
        bottom: 9,
        top: 9,
        right: 15,
        left: 15,
      )
    : const EdgeInsets.only(top: 11, bottom: 11, left: 15, right: 15);

double get inputHeight => AppConfig.isMobilePlatform
    ? 40
    : AppConfig.yaruStyled
        ? kYaruTitleBarItemHeight
        : 36;

double get audioCardDimension =>
    kAudioCardDimension - (AppConfig.isMobilePlatform ? 15 : 0);

double get bottomPlayerDefaultHeight =>
    AppConfig.isMobilePlatform ? 76.0 : 90.0;

double get navigationBarHeight => bottomPlayerDefaultHeight;

double? get bottomPlayerPageGap => AppConfig.isMobilePlatform
    ? bottomPlayerDefaultHeight + navigationBarHeight + kLargestSpace
    : null;

EdgeInsets get playerTopControlsPadding => EdgeInsets.only(
      right: kLargestSpace,
      top: Platform.isMacOS
          ? 0
          : AppConfig.isMobilePlatform
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
