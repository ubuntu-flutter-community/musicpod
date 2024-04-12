import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../get.dart';

import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../constants.dart';
import '../../external_path.dart';
import '../../library.dart';
import '../../patch_notes.dart';
import '../../player.dart';
import '../../settings.dart';
import 'master_detail_page.dart';

class App extends StatefulWidget with WatchItStatefulWidgetMixin {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    if (!isMobile) {
      YaruWindow.of(context).onClose(
        () async {
          await di.reset();
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
      await di.reset();
    }
  }

  void _init() {
    final libraryModel = getIt<LibraryModel>();
    final appModel = getIt<AppModel>();
    final settingsModel = getIt<SettingsModel>();
    final playerModel = getIt<PlayerModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      appModel.init().then(
        (_) {
          libraryModel.init().then(
            (_) {
              playerModel.init().then((_) {
                settingsModel.init();
                if (settingsModel.recentPatchNotesDisposed == false) {
                  showPatchNotes(context);
                }
              }).then((_) => getIt<ExternalPathService>().init());
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
