import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaru/yaru.dart';

import '../../../app.dart';
import '../../../build_context_x.dart';
import '../../../constants.dart';
import '../../../external_path.dart';
import '../../../get.dart';
import '../../../library.dart';
import '../../../patch_notes.dart';
import '../../../player.dart';
import '../../../settings.dart';
import 'master_detail_page.dart';

class MusicPodScaffold extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MusicPodScaffold({super.key});

  @override
  State<MusicPodScaffold> createState() => _MusicPodScaffoldState();
}

class _MusicPodScaffoldState extends State<MusicPodScaffold>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    if (!isMobile) {
      YaruWindow.of(context).onClose(
        () async {
          await getIt.reset();
          return true;
        },
      );
    }

    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await getIt.reset();
    }
  }

  void _init() {
    final libraryModel = getIt<LibraryModel>();
    final appModel = getIt<AppModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Init here for connectivity
      appModel.init().then(
        (_) {
          // Init here for the index
          libraryModel.init().then(
            (_) {
              // Init here for when musicpod is called with a file path
              getIt<ExternalPathService>().init();
              // Init here for patch notes dialog
              if (getIt<SettingsModel>().recentPatchNotesDisposed == false) {
                showPatchNotes(context);
              }
            },
          );
        },
      );
    });
  }

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
