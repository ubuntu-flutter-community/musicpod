import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:watch_it/watch_it.dart';

import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';
import '../../player/view/bottom_player.dart';
import '../app_model.dart';
import 'mobile_navigation_bar.dart';

class MobileBottomBar extends StatelessWidget with WatchItMixin {
  const MobileBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color = watchPropertyValue((PlayerModel m) => m.color);

    return SizedBox(
      width: context.mediaQuerySize.width,
      child: RepaintBoundary(
        child: Material(
          color: color == null
              ? theme.cardColor
              : Color.alphaBlend(
                  color.withAlpha(theme.isLight ? 20 : 15),
                  theme.scaffoldBackgroundColor.scale(
                    lightness: theme.isLight ? -0.01 : 0.05,
                  ),
                ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! < 150) {
                    di<AppModel>().setFullWindowMode(true);
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
}
