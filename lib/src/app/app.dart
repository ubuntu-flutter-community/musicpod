import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../constants.dart';
import '../../external_path.dart';
import '../../patch_notes.dart';
import '../../player.dart';
import 'master_detail_page.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    if (!isMobile) {
      YaruWindow.of(context).onClose(
        () async {
          await resetAllServices();
          return true;
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showPatchNotes(context, ref);
      getService<ExternalPathService>().init();
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

    final lockSpace = ref.watch(appModelProvider.select((a) => a.lockSpace));
    final isFullScreen =
        ref.watch(appModelProvider.select((a) => a.fullScreen));
    final playerModel = ref.read(playerModelProvider);

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
