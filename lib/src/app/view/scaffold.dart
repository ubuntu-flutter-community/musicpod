import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../build_context_x.dart';
import '../../../constants.dart';
import '../../../get.dart';
import '../../../player.dart';
import '../app_model.dart';
import 'master_detail_page.dart';

class MusicPodScaffold extends StatelessWidget with WatchItMixin {
  const MusicPodScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final playerToTheRight = context.m.size.width > kSideBarThreshHold;
    final lockSpace = watchPropertyValue((AppModel m) => m.lockSpace);
    final isFullScreen = watchPropertyValue((AppModel m) => m.fullScreen);
    final playerModel = getIt<PlayerModel>();

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (value) async {
        if (value.runtimeType == KeyDownEvent &&
            value.logicalKey == LogicalKeyboardKey.space) {
          if (!lockSpace) {
            playerModel.playOrPause();
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Expanded(child: MasterDetailPage()),
                    if (!playerToTheRight)
                      const PlayerView(mode: PlayerViewMode.bottom),
                  ],
                ),
              ),
              if (playerToTheRight)
                const SizedBox(
                  width: kSideBarPlayerWidth,
                  child: PlayerView(mode: PlayerViewMode.sideBar),
                ),
            ],
          ),
          if (isFullScreen == true)
            const Scaffold(
              body: PlayerView(mode: PlayerViewMode.fullWindow),
            ),
        ],
      ),
    );
  }
}
