import 'package:flutter/material.dart';

import 'sliver_filter_app_bar.dart';
import 'theme.dart';
import 'ui_constants.dart';

class DefaultPageBody extends StatelessWidget {
  const DefaultPageBody({
    super.key,
    required this.controlPanel,
    required this.sliverContentBuilder,
    this.onStretchTrigger,
    this.controlPanelSuffix,
    this.onNotification,
  });

  final Widget controlPanel;
  final Widget? controlPanelSuffix;

  final Widget Function(BuildContext context, BoxConstraints constraints)
  sliverContentBuilder;
  final Future<void> Function()? onStretchTrigger;
  final bool Function(ScrollNotification event)? onNotification;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => NotificationListener(
      onNotification: onNotification,
      child: CustomScrollView(
        slivers: [
          SliverFilterAppBar(
            padding: kGridPadding.copyWith(
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
            padding: kGridPadding.copyWith(bottom: bottomPlayerPageGap),
            sliver: sliverContentBuilder(context, constraints),
          ),
        ],
      ),
    ),
  );
}
