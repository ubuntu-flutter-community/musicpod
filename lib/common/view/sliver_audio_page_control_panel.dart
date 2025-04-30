import 'package:flutter/material.dart';

import '../../extensions/build_context_x.dart';
import 'sliver_app_bar_bottom_space.dart';
import 'ui_constants.dart';

class SliverAudioPageControlPanel extends StatelessWidget {
  const SliverAudioPageControlPanel({
    super.key,
    required this.controlPanel,
    this.onStretchTrigger,
    this.backgroundColor,
  });

  final Widget controlPanel;
  final Future<void> Function()? onStretchTrigger;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 10),
      sliver: SliverAppBar(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        elevation: 0,
        backgroundColor:
            backgroundColor ?? context.theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        pinned: true,
        centerTitle: true,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kLargestSpace),
          child: controlPanel,
        ),
        bottom: const SliverAppBarBottomSpace(),
        onStretchTrigger: onStretchTrigger,
      ),
    );
  }
}
