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
    final color = watchPropertyValue(
      (PlayerModel m) {
        final theme = context.theme;
        return Color.alphaBlend(
          m.color?.withAlpha(theme.isLight ? 20 : 40) ??
              theme.scaffoldBackgroundColor,
          context.theme.scaffoldBackgroundColor,
        );
      },
    );
    return SizedBox(
      width: context.mediaQuerySize.width,
      child: RepaintBoundary(
        child: Material(
          color: color,
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
