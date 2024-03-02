import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../constants.dart';
import '../../external_path.dart';
import '../../library.dart';
import '../../patch_notes.dart';
import '../../player.dart';
import '../settings/settings_model.dart';
import 'master_detail_page.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  String? _countryCode;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _countryCode = WidgetsBinding.instance.platformDispatcher.locale.countryCode
        ?.toLowerCase();

    final libraryModel = ref.read(libraryModelProvider);
    final settingsModel = ref.read(settingsModelProvider);
    final playerModel = ref.read(playerModelProvider);
    final appModel = ref.read(appModelProvider);

    if (!Platform.isAndroid && !Platform.isIOS) {
      YaruWindow.of(context).onClose(
        () async {
          await resetAllServices();
          return true;
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      appModel.init().then(
        (_) {
          libraryModel.init().then(
            (_) {
              playerModel.init().then((_) {
                if (settingsModel.recentPatchNotesDisposed == false) {
                  showPatchNotes(
                    context,
                    settingsModel.disposePatchNotes,
                  );
                }
              }).then((_) => getService<ExternalPathService>().init());
            },
          );
        },
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await resetAllServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerToTheRight = context.m.size.width > kSideBarThreshHold;

    final appModel = ref.read(appModelProvider);
    final isFullScreen =
        ref.watch(appModelProvider.select((value) => value.fullScreen));
    final playerModel = ref.read(playerModelProvider);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (value) async {
        if (value.runtimeType == KeyDownEvent &&
            value.logicalKey == LogicalKeyboardKey.space) {
          if (!appModel.lockSpace) {
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
                    Expanded(
                      child: MasterDetailPage(
                        countryCode: _countryCode,
                      ),
                    ),
                    if (!playerToTheRight)
                      const PlayerView(
                        playerViewMode: PlayerViewMode.bottom,
                      ),
                  ],
                ),
              ),
              if (playerToTheRight)
                const SizedBox(
                  width: kSideBarPlayerWidth,
                  child: PlayerView(
                    playerViewMode: PlayerViewMode.sideBar,
                  ),
                ),
            ],
          ),
          if (isFullScreen == true)
            const Scaffold(
              body: PlayerView(
                playerViewMode: PlayerViewMode.fullWindow,
              ),
            ),
        ],
      ),
    );
  }
}
