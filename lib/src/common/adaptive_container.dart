import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../theme_data_x.dart';

class AdaptiveContainer extends StatelessWidget {
  const AdaptiveContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final smallWindow = context.m.size.width < 1200;

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
            color: smallWindow
                ? null
                : theme.colorScheme.onSurface
                    .withOpacity(theme.isLight ? 0.04 : 0.03),
            padding: smallWindow
                ? EdgeInsets.zero
                : const EdgeInsets.only(top: kYaruPagePadding),
            border: Border.all(
              color: Colors.transparent,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
