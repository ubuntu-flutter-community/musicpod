import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
import '../../player/view/bottom_player.dart';
import '../app_manager.dart';
import 'mobile_navigation_bar.dart';

class MobileBottomBar extends StatelessWidget {
  const MobileBottomBar({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: context.mediaQuerySize.width,
    child: RepaintBoundary(
      child: Material(
        color: context.theme.cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < 150) {
                  di<AppManager>().setFullWindowMode(true);
                }
              },
              child: const BottomPlayer(),
            ),
            const MobileNavigationBar(),
          ],
        ),
      ),
    ),
  );
}
