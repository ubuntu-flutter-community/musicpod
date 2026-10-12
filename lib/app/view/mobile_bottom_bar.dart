import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/build_context_x.dart';
import '../../player/view/bottom_player.dart';
import '../full_window_mode_manager.dart';
import 'mobile_navigation_bar.dart';

class MobileBottomBar extends ConsumerWidget {
  const MobileBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SizedBox(
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
                  ref
                      .read(fullWindowModeManagerProvider.notifier)
                      .setFullWindowMode(true);
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
