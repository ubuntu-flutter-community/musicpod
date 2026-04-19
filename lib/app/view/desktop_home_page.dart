import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../player/view/player_view.dart';
import '../../podcasts/download_manager.dart';
import '../../settings/settings_model.dart';
import '../app_manager.dart';
import 'master_detail_page.dart';

class DesktopHomePage extends StatelessWidget with WatchItMixin {
  const DesktopHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final autoMovePlayer = watchPropertyValue(
      (SettingsModel m) => m.autoMovePlayer,
    );

    final playerToTheRight =
        autoMovePlayer && context.mediaQuerySize.width > kSideBarThreshHold;

    final isInFullWindowMode =
        watchValue((AppManager m) => m.fullWindowMode) ?? false;

    registerStreamHandler(
      select: (DownloadManager m) => m.messageStream,
      handler: downloadMessageStreamHandler,
    );

    // This scaffold is mainly used to have a unified place for snackbars
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              const Expanded(child: const MasterDetailPage()),
              if (playerToTheRight)
                const SizedBox(
                  width: kSideBarPlayerWidth,
                  child: PlayerView.sideBar(),
                ),
            ],
          ),
          if (isInFullWindowMode) const PlayerView.fullWindow(),
        ],
      ),
      bottomNavigationBar: !playerToTheRight && !isInFullWindowMode
          ? const PlayerView.bottom()
          : null,
    );
  }
}
