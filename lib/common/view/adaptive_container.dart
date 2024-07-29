import 'dart:math';

import 'package:flutter/material.dart';

EdgeInsets getAdaptiveHorizontalPadding({
  required BoxConstraints constraints,
  double min = 15,
}) {
  return EdgeInsets.symmetric(
    horizontal: max((constraints.maxWidth - 650) / 2, 0) > min
        ? max((constraints.maxWidth - 650) / 2, 0)
        : min,
  );
}
