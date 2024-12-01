import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../extensions/build_context_x.dart';
import '../../player/view/full_height_player.dart';
import '../../player/view/player_view.dart';
import '../app_model.dart';
import 'mobile_bottom_bar.dart';

class MobilePage extends StatelessWidget with WatchItMixin {
  const MobilePage({
    super.key,
    required this.page,
  });

  final Widget page;

  @override
  Widget build(BuildContext context) {
    final fullWindowMode =
        watchPropertyValue((AppModel m) => m.fullWindowMode) ?? false;

    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          page,
          if (fullWindowMode)
            const Hero(
              tag: 'full_height_player',
              child: Scaffold(
                extendBody: true,
                extendBodyBehindAppBar: true,
                body: FullHeightPlayer(
                  playerPosition: PlayerPosition.fullWindow,
                ),
              ),
            )
          else
            const Positioned(
              bottom: 0,
              child: MobileBottomBar(),
            ),
        ],
      ),
    );
  }
}
