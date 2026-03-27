import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:window_manager/window_manager.dart';

import '../app/app_config.dart';

@module
abstract class WindowManagerModule {
  @preResolve
  Future<WindowManager> create() async {
    final wm = WindowManager.instance;
    if (AppConfig.windowManagerImplemented) {
      await wm.ensureInitialized();
      await wm.waitUntilReadyToShow(
        const WindowOptions(
          backgroundColor: Colors.transparent,
          minimumSize: Size(500, 700),
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.hidden,
        ),
        () async {
          await windowManager.show();
          await windowManager.focus();
        },
      );
    }

    return wm;
  }
}
