import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/taget_platform_x.dart';
import 'icons.dart';
import 'ui_constants.dart';

ThemeData? yaruDarkWithTweaks(ThemeData? darkTheme) {
  return darkTheme?.copyWith(
    textTheme:
        isLinux ? null : createTextTheme(darkTheme.colorScheme.onSurface),
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) => Icon(Iconz.goBack),
    ),
    scaffoldBackgroundColor: darkTheme.scaffoldBackgroundColor.scale(
      lightness: -0.35,
    ),
    dividerColor: yaruFixDarkDividerColor,
    dividerTheme: const DividerThemeData(
      color: yaruFixDarkDividerColor,
      space: 1.0,
      thickness: 0.0,
    ),
    cardColor: darkTheme.cardColor.scale(
      lightness: -0.2,
    ),
    iconButtonTheme: iconButtonTheme(darkTheme),
  );
}

ThemeData? yaruLightWithTweaks(ThemeData? theme) {
  return theme?.copyWith(
    textTheme: isLinux ? null : createTextTheme(theme.colorScheme.onSurface),
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) => Icon(Iconz.goBack),
    ),
    cardColor: theme.dividerColor.scale(
      lightness: -0.01,
    ),
    iconButtonTheme: iconButtonTheme(theme),
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
    isMobile ? kMobileSearchBarWidth : kDesktopSearchBarWidth;

double getSearchBarBorderRadius(bool useYaruTheme) =>
    useYaruTheme ? kYaruButtonRadius : 100;

Color? audioFilterBackgroundColor({
  required ThemeData theme,
  required bool selected,
  required bool useYaruTheme,
}) =>
    selected
        ? useYaruTheme
            ? theme.colorScheme.onSurface.withValues(alpha: 0.15)
            : (theme.chipTheme.selectedColor ?? theme.colorScheme.primary)
        : null;

Color? audioFilterForegroundColor({
  required ThemeData theme,
  required bool selected,
  required bool useYaruTheme,
}) =>
    selected
        ? theme.colorScheme.isDark
            ? Colors.white
            : Colors.black
        : theme.colorScheme.onSurface.scale(alpha: useYaruTheme ? 1 : -0.3);

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
          width: isMobile ? 2 : 1,
          color: colorScheme.outline,
        ),
      );
  return InputDecoration(
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    suffixIconConstraints: BoxConstraints(
      maxHeight: isMobile ? kToolbarHeight : kYaruTitleBarItemHeight,
    ),
    hintText: hintText,
    fillColor: fillColor,
    filled: filled,
    contentPadding: isMobile
        ? const EdgeInsets.only(top: 16, bottom: 0, left: 15, right: 15)
        : contentPadding ??
            const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
    border: outlineInputBorder,
    errorBorder: outlineInputBorder,
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder.copyWith(
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: isMobile ? 2 : 1,
      ),
    ),
    disabledBorder: outlineInputBorder,
    focusedErrorBorder: outlineInputBorder,
    helperStyle: isMobile ? null : style,
    hintStyle: isMobile ? null : style,
    labelStyle: isMobile ? null : style,
    isDense: isMobile ? false : isDense,
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
    suffixIcon: suffixIcon,
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

double get sideBarImageSize => 38;

double getLikeButtonWidth(bool useYaruTheme) => useYaruTheme ? 62 : 70;

double get progressStrokeWidth => 3.0;

double getSmallAvatarButtonRadius(bool useYaruTheme) =>
    (useYaruTheme
        ? kYaruTitleBarItemHeight
        : isMobile
            ? 42
            : 38) /
    2;

double getBigAvatarButtonRadius(bool useYaruTheme) => useYaruTheme
    ? 22
    : isMobile
        ? 26
        : 23;

EdgeInsets get filterPanelPadding =>
    EdgeInsets.only(top: isMobile ? 10 : 0, bottom: 10);

EdgeInsets getBigPlayButtonPadding(bool useYaruTheme) =>
    EdgeInsets.symmetric(horizontal: useYaruTheme ? 2.5 : 5);

double get chipHeight => isMobile ? 40 : 34.0;

EdgeInsets get audioTilePadding => kAudioTilePadding;

SliverGridDelegate get audioCardGridDelegate =>
    isMobile ? kMobileAudioCardGridDelegate : kAudioCardGridDelegate;

EdgeInsets get appBarSingleActionSpacing => isMacOS
    ? const EdgeInsets.only(right: 5, left: 5)
    : EdgeInsets.only(
        right: 10,
        left: isMobile ? 0 : kLargestSpace,
      );

EdgeInsetsGeometry getRadioHistoryListPadding(bool useYaruTheme) =>
    EdgeInsets.only(left: useYaruTheme ? 0 : 5);

EdgeInsets get mainPageIconPadding => kMainPageIconPadding;

EdgeInsets getCountryPillPadding(bool useYaruTheme) => useYaruTheme
    ? const EdgeInsets.only(
        bottom: 9,
        top: 9,
        right: 15,
        left: 15,
      )
    : const EdgeInsets.only(top: 11, bottom: 11, left: 15, right: 15);

double getInputHeight(bool useYaruTheme) => isMobile
    ? 40
    : useYaruTheme
        ? kYaruTitleBarItemHeight
        : 36;

double get audioCardDimension => kAudioCardDimension - (isMobile ? 15 : 0);

double get bottomPlayerDefaultHeight => isMobile ? 76.0 : 90.0;

double get navigationBarHeight => bottomPlayerDefaultHeight;

double? get bottomPlayerPageGap => isMobile
    ? bottomPlayerDefaultHeight + navigationBarHeight + kLargestSpace
    : null;

EdgeInsets get playerTopControlsPadding => EdgeInsets.only(
      right: kLargestSpace,
      top: isMacOS
          ? 0
          : isMobile
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

TextTheme createTextTheme(Color textColor) {
  return TextTheme(
    displayLarge: _TextStyle(
      fontSize: 96,
      fontWeight: FontWeight.w300,
      textColor: textColor,
    ),
    displayMedium: _TextStyle(
      fontSize: 60,
      fontWeight: FontWeight.w300,
      textColor: textColor,
    ),
    displaySmall: _TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.normal,
      textColor: textColor,
    ),
    headlineLarge: _TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.normal,
      textColor: textColor,
    ),
    headlineMedium: _TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.normal,
      textColor: textColor,
    ),
    headlineSmall: _TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.normal,
      textColor: textColor,
    ),
    titleLarge: _TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      textColor: textColor,
    ),
    titleMedium: _TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      textColor: textColor,
    ),
    titleSmall: _TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      textColor: textColor,
    ),
    bodyLarge: _TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      textColor: textColor,
    ),
    bodyMedium: _TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      textColor: textColor,
    ),
    bodySmall: _TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      textColor: textColor,
    ),
    labelLarge: _TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      textColor: textColor,
    ),
    labelMedium: _TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      textColor: textColor,
    ),
    labelSmall: _TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      textColor: textColor,
    ),
  );
}

class _TextStyle extends TextStyle {
  const _TextStyle({
    super.fontSize,
    super.fontWeight,
    required this.textColor,
  }) : super(
          fontFamily: 'CupertinoSystemText',
          color: textColor,
        );
  final Color textColor;
}
