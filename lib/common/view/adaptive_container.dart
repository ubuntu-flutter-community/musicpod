import 'dart:math';

import 'package:flutter/material.dart';

EdgeInsets getAdaptiveHorizontalPadding({
  required BoxConstraints constraints,
  double min = 15,
  double limit = 1000,
}) {
  final m = max((constraints.maxWidth - limit) / 2, 0).toDouble();
  return EdgeInsets.symmetric(
    horizontal: m > min ? m : min,
  );
}
