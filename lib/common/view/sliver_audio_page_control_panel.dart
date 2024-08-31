import 'package:flutter/material.dart';
import 'package:yaru/constants.dart';

import '../../extensions/build_context_x.dart';

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
        backgroundColor: backgroundColor ?? context.t.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        pinned: true,
        centerTitle: true,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kYaruPagePadding),
          child: controlPanel,
        ),
        bottom: const _Space(),
        onStretchTrigger: onStretchTrigger,
      ),
    );
  }
}

class _Space extends StatelessWidget implements PreferredSizeWidget {
  const _Space();

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  @override
  Size get preferredSize => const Size(0, 10);
}
