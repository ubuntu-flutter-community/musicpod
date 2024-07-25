import 'dart:math';

import 'package:flutter/material.dart';

EdgeInsets getAdaptiveHorizontalPadding(BoxConstraints constraints) {
  return EdgeInsets.symmetric(
    horizontal: max((constraints.maxWidth - 650) / 2, 0) > 15
        ? max((constraints.maxWidth - 650) / 2, 0)
        : 15,
  );
}
