import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../constants.dart';
import '../../library.dart';
import '../../patch_notes.dart';
import '../../player.dart';
import '../external_path/external_path_service.dart';
import 'connectivity_notifier.dart';
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
    final playerModel = ref.read(playerModelProvider);

    final connectivityNotifier = ref.read(connectivityNotifierProvider);

    final extPathService = getService<ExternalPathService>();

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
      connectivityNotifier.init().then(
        (_) {
          libraryModel.init().then(
            (_) {
              playerModel.init().then((_) {
                if (libraryModel.recentPatchNotesDisposed == false) {
                  showPatchNotes(context, libraryModel.disposePatchNotes);
                }
                extPathService.init(playerModel.play);
              });
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
      await ref.read(libraryModelProvider).safeStates();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerToTheRight = context.m.size.width > kSideBarThreshHold;

    // AppModel
    final isFullScreen =
        ref.watch(appModelProvider.select((value) => value.fullScreen));

    final playerModel = ref.read(playerModelProvider);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (value) {
        if (value.runtimeType == KeyDownEvent &&
            value.logicalKey == LogicalKeyboardKey.space) {
          playerModel.playOrPause();
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
