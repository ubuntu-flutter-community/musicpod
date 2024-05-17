import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../build_context_x.dart';
import '../../../constants.dart';
import '../../../get.dart';
import '../../../player.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../settings/settings_model.dart';
import '../app_model.dart';
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
    final settingsModel = getIt<SettingsModel>();
    settingsModel.checkForUpdate(getIt<PlayerModel>().isOnline).then((_) {
      if (!mounted) return;
      if (settingsModel.recentPatchNotesDisposed == false) {
        showPatchNotes(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerToTheRight = context.m.size.width > kSideBarThreshHold;
    final lockSpace = watchPropertyValue((AppModel m) => m.lockSpace);
    final isFullScreen = watchPropertyValue((AppModel m) => m.fullWindowMode);
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
