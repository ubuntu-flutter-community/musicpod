import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import 'mobile_navigation_bar.dart';

class MusicPodScaffold extends StatelessWidget with WatchItMixin {
  const MusicPodScaffold({super.key, required this.body, this.appBar});

  final Widget body;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: isMobile ? false : null,
        body: isMobile ? SafeArea(child: body) : body,
        appBar: appBar,
        bottomNavigationBar:
            isMobile ? const MobilePlayerAndNavigationBar() : null,
      );
}
