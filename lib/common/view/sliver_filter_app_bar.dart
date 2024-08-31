import 'package:flutter/material.dart';

import '../../extensions/build_context_x.dart';

class SliverFilterAppBar extends StatelessWidget {
  const SliverFilterAppBar({
    super.key,
    this.onStretchTrigger,
    required this.title,
    required this.padding,
  });

  final Future<void> Function()? onStretchTrigger;
  final Widget title;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverAppBar(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        elevation: 0,
        backgroundColor: context.t.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        pinned: true,
        centerTitle: true,
        titleSpacing: 0,
        stretch: true,
        title: title,
        onStretchTrigger: onStretchTrigger,
      ),
    );
  }
}
