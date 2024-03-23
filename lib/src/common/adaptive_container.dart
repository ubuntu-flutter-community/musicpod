import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';

class AdaptiveContainer extends StatelessWidget {
  const AdaptiveContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final smallWindow = context.m.size.width < 1800;

    return Center(
      child: Container(
        padding: smallWindow
            ? EdgeInsets.zero
            : const EdgeInsets.all(kYaruPagePadding),
        width: smallWindow ? double.infinity : 1000,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kYaruContainerRadius),
          child: YaruBorderContainer(
            padding: smallWindow
                ? EdgeInsets.zero
                : const EdgeInsets.only(top: kYaruPagePadding),
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
