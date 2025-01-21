import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/bandwidth_dialog.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/connectivity_x.dart';
import '../../player/player_model.dart';
import '../../player/view/full_height_player.dart';
import '../../player/view/player_view.dart';
import '../../podcasts/download_model.dart';
import '../../podcasts/podcast_model.dart';
import '../../podcasts/podcast_search_state.dart';
import '../../podcasts/view/podcast_snackbar_contents.dart';
import '../../settings/settings_model.dart';
import '../app_model.dart';
import '../connectivity_model.dart';
import 'mobile_bottom_bar.dart';

class MobilePage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MobilePage({
    super.key,
    required this.page,
  });

  final Widget page;

  @override
  State<MobilePage> createState() => _MobilePageState();
}

class _MobilePageState extends State<MobilePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (di<SettingsModel>().notifyDataSafeMode &&
          di<ConnectivityModel>().isMaybeLowBandWidth &&
          !di<PlayerModel>().dataSafeMode) {
        showDialog(
          context: context,
          builder: (context) => const BandwidthDialog(),
        );
      }
    });
  }

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

    final dataSafeMode = watchPropertyValue((PlayerModel m) => m.dataSafeMode);
    final notifyDataSafeMode =
        watchPropertyValue((SettingsModel m) => m.notifyDataSafeMode);

    registerStreamHandler(
      select: (Connectivity m) => m.onConnectivityChanged,
      handler: (context, res, cancel) {
        if (notifyDataSafeMode && res.hasData) {
          if (di<Connectivity>().isMaybeLowBandWidth(res.data) &&
              !dataSafeMode) {
            showDialog(
              context: context,
              builder: (context) => const BandwidthDialog(),
            );
          } else if (!di<Connectivity>().isMaybeLowBandWidth(res.data) &&
              dataSafeMode) {
            showDialog(
              context: context,
              builder: (context) => const BandwidthDialog(
                backOnBetterConnection: true,
              ),
            );
          }
        }
      },
    );

    registerStreamHandler(
      select: (PodcastModel m) => m.stateStream,
      initialValue: null,
      handler: (context, newValue, cancel) {
        if (newValue.hasData) {
          if (newValue.data == PodcastSearchState.done) {
            ScaffoldMessenger.of(context).clearSnackBars();
          } else {
            showSnackBar(
              context: context,
              content: switch (newValue.data) {
                PodcastSearchState.loading =>
                  const PodcastSearchLoadingSnackBarContent(),
                PodcastSearchState.empty =>
                  const PodcastSearchEmptyFeedSnackBarContent(),
                PodcastSearchState.timeout =>
                  const PodcastSearchTimeoutSnackBarContent(),
                _ => const SizedBox.shrink()
              },
              duration: switch (newValue.data) {
                PodcastSearchState.loading => const Duration(seconds: 1000),
                _ => const Duration(seconds: 3),
              },
            );
          }
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
          widget.page,
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
