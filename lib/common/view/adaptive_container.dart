import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class AdaptiveContainer extends StatelessWidget {
  const AdaptiveContainer({super.key, required this.child, this.padding});
  final Widget child;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(
          top: isMobile ? kYaruPagePadding : 0,
          bottom: kYaruPagePadding,
        ),
        // width: 650,
        child: child,
      ),
    );
  }
}

EdgeInsets getSliverHorizontalPadding(BoxConstraints constraints) {
  return EdgeInsets.symmetric(
    horizontal: max((constraints.maxWidth - 650) / 2, 0) > 15
        ? max((constraints.maxWidth - 650) / 2, 0)
        : 15,
  );
}
