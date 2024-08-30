import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../player/view/player_view.dart';
import '../app_model.dart';
import '../connectivity_model.dart';
import 'master_detail_page.dart';

class MusicPodScaffold extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MusicPodScaffold({super.key});

  @override
  State<MusicPodScaffold> createState() => _MusicPodScaffoldState();
}

class _MusicPodScaffoldState extends State<MusicPodScaffold> {
  @override
  void initState() {
    super.initState();
    final appModel = di<AppModel>();
    appModel
        .checkForUpdate(di<ConnectivityModel>().isOnline == true, context)
        .then((_) {
      if (!appModel.recentPatchNotesDisposed() && mounted) {
        showDialog(
          context: context,
          builder: (_) => const PatchNotesDialog(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerToTheRight = context.m.size.width > kSideBarThreshHold;
    final isFullScreen = watchPropertyValue((AppModel m) => m.fullWindowMode);

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Expanded(child: MasterDetailPage()),
                  if (!playerToTheRight || isMobile)
                    const PlayerView(mode: PlayerPosition.bottom),
                ],
              ),
            ),
            if (playerToTheRight)
              const SizedBox(
                width: kSideBarPlayerWidth,
                child: PlayerView(mode: PlayerPosition.sideBar),
              ),
          ],
        ),
        if (isFullScreen == true)
          const Scaffold(body: PlayerView(mode: PlayerPosition.fullWindow)),
      ],
    );
  }
}
