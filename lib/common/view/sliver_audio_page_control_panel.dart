import 'package:flutter/material.dart';
import 'package:yaru/constants.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';

class SliverAudioPageControlPanel extends StatelessWidget {
  const SliverAudioPageControlPanel({super.key, required this.controlPanel});

  final Widget controlPanel;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final wrappedInContainer = context.wideWindow;
    final smallWindow = context.smallWindow;

    final color =
        wrappedInContainer ? theme.scaffoldBackgroundColor : theme.containerBg;

    return SliverAppBar(
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      elevation: 0,
      backgroundColor: color,
      automaticallyImplyLeading: false,
      pinned: true,
      centerTitle: smallWindow,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kYaruPagePadding),
        child: controlPanel,
      ),
      bottom: const _Space(),
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
