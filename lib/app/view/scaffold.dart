import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch_it/watch_it.dart';

import '../../player/player_model.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../player/view/player_view.dart';
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
    final settingsModel = di<SettingsModel>();
    settingsModel.checkForUpdate(di<PlayerModel>().isOnline).then((_) {
      if (!mounted) return;
      if (settingsModel.recentPatchNotesDisposed == false) {
        showPatchNotes(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lockSpace = watchPropertyValue((AppModel m) => m.lockSpace);
    final isFullScreen = watchPropertyValue((AppModel m) => m.fullWindowMode);
    final playerModel = di<PlayerModel>();

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
          const Column(
            children: [
              Expanded(child: MasterDetailPage()),
              // TODO: add bottom bar for mobile for Library / Search

              PlayerView(mode: PlayerPosition.bottom),
            ],
          ),
          if (isFullScreen == true)
            const Scaffold(
              body: PlayerView(mode: PlayerPosition.fullWindow),
            ),
        ],
      ),
    );
  }
}
