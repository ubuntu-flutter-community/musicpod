import 'dart:async';
import 'dart:ui';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app_config.dart';
import '../player/player_service.dart';
import '../settings/shared_preferences_keys.dart';
import '../extensions/taget_platform_x.dart';

@singleton
class WindowSizeToSettingsListener implements WindowListener {
  WindowSizeToSettingsListener({
    required SharedPreferences sharedPreferences,
    required PlayerService playerService,
    required WindowManager windowManager,
  }) : _sp = sharedPreferences,
       _playerService = playerService,
       _windowManager = windowManager {
    windowManager.addListener(this);
  }

  final WindowManager _windowManager;

  final SharedPreferences _sp;
  final PlayerService _playerService;

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    if (!AppConfig.windowManagerImplemented) return;

    if (_sp.getBool(SPKeys.saveWindowSize) == null) {
      await _sp.setBool(SPKeys.saveWindowSize, true);
    }

    if (_sp.getBool(SPKeys.windowFullscreen) ?? false) {
      await _windowManager.setFullScreen(true);
    } else if (_sp.getBool(SPKeys.windowMaximized) ?? false) {
      await _windowManager.maximize();
    } else {
      final height = _sp.getInt(SPKeys.windowHeight) ?? 820;
      final width = _sp.getInt(SPKeys.windowWidth) ?? 950;
      await _windowManager.setSize(Size(width.toDouble(), height.toDouble()));
    }
  }

  @override
  void onWindowBlur() {}

  @override
  void onWindowClose() {
    _playerService.persistPlayerState();
  }

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

  // Note: linux and windows do not have window resized, so we need to use window resize
  // and debounce it
  Timer? _debounce;
  void dispose() => _debounce?.cancel();
  @override
  void onWindowResize() {
    if (isLinux || isWindows) {
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
    if (isMacOS) {
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
