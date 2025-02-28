import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_config.dart';

EdgeInsets getAdaptiveHorizontalPadding({
  required BoxConstraints constraints,
  double min = 15,
}) {
  return EdgeInsets.symmetric(
    horizontal: isMobilePlatform
        ? min
        : max((constraints.maxWidth - 850) / 2, 0) > min
            ? max((constraints.maxWidth - 850) / 2, 0)
            : min,
  );
}
