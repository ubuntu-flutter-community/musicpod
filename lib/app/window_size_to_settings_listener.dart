import 'dart:async';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../settings/shared_preferences_keys.dart';
import '../extensions/taget_platform_x.dart';

class WindowSizeToSettingsListener implements WindowListener {
  WindowSizeToSettingsListener({required SharedPreferences sharedPreferences})
    : _sp = sharedPreferences;

  final SharedPreferences _sp;

  static Future<WindowSizeToSettingsListener> register({
    required SharedPreferences sharedPreferences,
    required WindowManager windowManager,
  }) async {
    final wm = windowManager;
    final sp = sharedPreferences;
    if (sp.getBool(SPKeys.saveWindowSize) == null) {
      await sp.setBool(SPKeys.saveWindowSize, true);
    }

    if (sp.getBool(SPKeys.windowFullscreen) ?? false) {
      await wm.setFullScreen(true);
    } else if (sp.getBool(SPKeys.windowMaximized) ?? false) {
      await wm.maximize();
    } else {
      final height = sp.getInt(SPKeys.windowHeight) ?? 820;
      final width = sp.getInt(SPKeys.windowWidth) ?? 950;
      await wm.setSize(Size(width.toDouble(), height.toDouble()));
    }

    final windowSizeToSettingsListener = WindowSizeToSettingsListener(
      sharedPreferences: sp,
    );
    wm.addListener(windowSizeToSettingsListener);

    return windowSizeToSettingsListener;
  }

  @override
  void onWindowBlur() {}

  @override
  void onWindowClose() {}

  @override
  void onWindowDocked() {}

  @override
  void onWindowEnterFullScreen() => _sp.setBool(SPKeys.windowFullscreen, true);

  @override
  void onWindowEvent(String eventName) {}

  @override
  void onWindowFocus() {}

  @override
  void onWindowLeaveFullScreen() => _sp.setBool(SPKeys.windowFullscreen, false);

  @override
  void onWindowMaximize() => _sp.setBool(SPKeys.windowMaximized, true);

  @override
  void onWindowMinimize() {}

  @override
  void onWindowMove() {}

  @override
  void onWindowMoved() {}

  // Note: linux does not have window resized, so we need to use window resize
  // and debounce it
  Timer? _debounce;
  void dispose() => _debounce?.cancel();
  @override
  void onWindowResize() {
    if (isLinux) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 5), () {
        WindowManager.instance.getSize().then((v) async {
          if (_sp.getBool(SPKeys.saveWindowSize) ?? false) {
            _sp
                .setInt(SPKeys.windowHeight, v.height.toInt())
                .then((_) => _sp.setInt(SPKeys.windowWidth, v.width.toInt()));
          }
        });
      });
    }
  }

  @override
  void onWindowResized() {
    if (isMacOS || isWindows) {
      WindowManager.instance.getSize().then((v) async {
        if (_sp.getBool(SPKeys.saveWindowSize) ?? false) {
          _sp
              .setInt(SPKeys.windowHeight, v.height.toInt())
              .then((_) => _sp.setInt(SPKeys.windowWidth, v.width.toInt()));
        }
      });
    }
  }

  @override
  void onWindowRestore() {}

  @override
  void onWindowUndocked() {}

  @override
  void onWindowUnmaximize() => _sp.setBool(SPKeys.windowMaximized, false);
}
