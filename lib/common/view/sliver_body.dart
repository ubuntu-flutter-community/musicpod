import 'package:flutter/material.dart';

import 'adaptive_container.dart';
import 'sliver_filter_app_bar.dart';
import 'theme.dart';
import 'ui_constants.dart';

class SliverBody extends StatelessWidget {
  const SliverBody({
    super.key,
    required this.controlPanel,
    required this.contentBuilder,
    this.onStretchTrigger,
    this.controlPanelSuffix,
    this.onNotification,
  });

  final Widget controlPanel;
  final Widget? controlPanelSuffix;

  final Widget Function(BuildContext context, BoxConstraints constraints)
  contentBuilder;
  final Future<void> Function()? onStretchTrigger;
  final bool Function(ScrollNotification event)? onNotification;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => NotificationListener(
      onNotification: onNotification,
      child: CustomScrollView(
        slivers: [
          SliverFilterAppBar(
            padding: getAdaptiveHorizontalPadding(constraints: constraints)
                .copyWith(
                  bottom: filterPanelPadding.bottom,
                  top: filterPanelPadding.top,
                ),

            title: controlPanel,
            actions: [
              if (controlPanelSuffix != null) ...[
                controlPanelSuffix!,
                const SizedBox(width: kSmallestSpace),
              ],
            ],
            onStretchTrigger: onStretchTrigger,
          ),
          SliverPadding(
            padding: getAdaptiveHorizontalPadding(
              constraints: constraints,
            ).copyWith(bottom: bottomPlayerPageGap),
            sliver: contentBuilder(context, constraints),
          ),
        ],
      ),
    ),
  );
}
