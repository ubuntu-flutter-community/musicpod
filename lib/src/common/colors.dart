import 'dart:io';

import 'package:flutter/material.dart';

bool get _l => Platform.isLinux;

Color? getSideBarColor(ThemeData theme) =>
    _l ? null : theme.scaffoldBackgroundColor;

Color getSnackBarTextColor(ThemeData theme) =>
    _l ? Colors.white.withOpacity(0.7) : theme.colorScheme.onInverseSurface;
