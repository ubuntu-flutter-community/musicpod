import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';
import '../../player/view/full_height_player.dart';
import '../../player/view/player_view.dart';
import '../../podcasts/download_model.dart';
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

    registerStreamHandler(
      select: (DownloadModel m) => m.messageStream,
      initialValue: null,
      handler: (context, snapshot, cancel) {
        if (snapshot.hasData) {
          showSnackBar(context: context, content: Text(snapshot.data ?? ''));
        }
      },
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          page,
          if (fullWindowMode)
            Material(
              color: context.theme.scaffoldBackgroundColor,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! > 150) {
                    di<AppModel>().setFullWindowMode(false);
                  }
                  di<PlayerModel>().bottomPlayerHeight =
                      bottomPlayerDefaultHeight;
                },
                child: const FullHeightPlayer(
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
