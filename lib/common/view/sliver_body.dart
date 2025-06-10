import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import 'adaptive_container.dart';
import 'icons.dart';
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

class GenericControlPanel extends StatelessWidget {
  const GenericControlPanel({
    super.key,
    required this.labels,
    required this.isSelected,
    required this.onSelected,
  });

  final List<Widget> labels;
  final List<bool> isSelected;
  final void Function(int index)? onSelected;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.center,
    child: YaruChoiceChipBar(
      clearOnSelect: false,
      selectedFirst: false,
      showCheckMarks: false,
      style: YaruChoiceChipBarStyle.stack,
      shrinkWrap: true,
      goNextIcon: Icon(Iconz.goNext),
      goPreviousIcon: Icon(Iconz.goBack),
      chipHeight: chipHeight,
      labels: labels,
      isSelected: isSelected,
      onSelected: onSelected,
    ),
  );
}
