import 'dart:io';

import 'package:flutter/material.dart';

bool get _yaruApp => Platform.isLinux;

Color? getSideBarColor(ThemeData theme) =>
    _yaruApp ? null : theme.scaffoldBackgroundColor;

Color getSnackBarTextColor(ThemeData theme) => _yaruApp
    ? Colors.white.withOpacity(0.7)
    : theme.colorScheme.onInverseSurface;

Color getPlayerBg(Color? surfaceTintColor, Color scaffoldBg) {
  if (surfaceTintColor != null) {
    return (Platform.isLinux
        ? surfaceTintColor
        : Color.alphaBlend(
            surfaceTintColor,
            scaffoldBg,
          ));
  } else {
    return scaffoldBg;
  }
}
