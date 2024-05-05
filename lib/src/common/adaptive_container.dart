import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../theme_data_x.dart';

class AdaptiveContainer extends StatelessWidget {
  const AdaptiveContainer({super.key, required this.child, this.padding});
  final Widget child;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final smallWindow = context.m.size.width < 1200;
    final color = smallWindow ? null : theme.containerBg;

    return Center(
      child: Container(
        padding: smallWindow
            ? EdgeInsets.zero
            : const EdgeInsets.only(
                left: kYaruPagePadding,
                right: kYaruPagePadding,
                bottom: kYaruPagePadding,
              ),
        width: smallWindow ? double.infinity : 800,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kYaruContainerRadius),
          child: YaruBorderContainer(
            color: color,
            padding: padding ??
                (smallWindow
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(top: kYaruPagePadding)),
            border: Border.all(
              color: smallWindow ? Colors.transparent : theme.dividerColor,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
