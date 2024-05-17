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
    final wrapInContainer = context.wideWindow;
    final color = wrapInContainer ? null : theme.containerBg;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: wrapInContainer
            ? EdgeInsets.zero
            : const EdgeInsets.only(
                left: kYaruPagePadding,
                right: kYaruPagePadding,
                bottom: kYaruPagePadding,
              ),
        width: wrapInContainer ? null : 800,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kYaruContainerRadius),
          child: YaruBorderContainer(
            color: color,
            padding: padding ??
                (wrapInContainer
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(top: kYaruPagePadding)),
            border: Border.all(
              color: wrapInContainer ? Colors.transparent : theme.dividerColor,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
