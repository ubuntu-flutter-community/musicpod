import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';
import '../../player/view/full_height_player.dart';
import '../../player/view/player_view.dart';
import '../../podcasts/download_model.dart';
import '../../podcasts/podcast_model.dart';
import '../../podcasts/view/podcast_state_stream_handler.dart';
import '../app_model.dart';
import '../connectivity_model.dart';
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
      handler: downloadMessageStreamHandler,
    );

    registerStreamHandler(
      select: (PodcastModel m) => m.stateStream,
      handler: podcastStateStreamHandler,
    );

    registerStreamHandler(
      select: (ConnectivityModel m) => m.onConnectivityChanged,
      handler: onConnectivityChangedHandler,
    );

    return PopScope(
      canPop: !fullWindowMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (fullWindowMode) {
          di<AppModel>().setFullWindowMode(false);
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
