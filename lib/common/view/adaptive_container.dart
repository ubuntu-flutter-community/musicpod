import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_config.dart';

EdgeInsets getAdaptiveHorizontalPadding({
  required BoxConstraints constraints,
  double min = 15,
}) {
  final m = max((constraints.maxWidth - 1000) / 2, 0).toDouble();
  return EdgeInsets.symmetric(
    horizontal: AppConfig.isMobilePlatform
        ? min
        : m > min
            ? m
            : min,
  );
}
