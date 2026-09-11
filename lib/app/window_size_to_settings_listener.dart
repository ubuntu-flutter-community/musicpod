import 'dart:async';
import 'dart:ui';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../common/logging.dart';
import 'app_config.dart';
import '../player/service/player_service.dart';
import '../settings/data/shared_preferences_keys.dart';
import '../extensions/platform_x.dart';

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

  bool _isClosing = false;
  Timer? _debounce;

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    if (!AppConfig.windowManagerImplemented) return;

    await _windowManager.setPreventClose(true);

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
  Future<void> onWindowClose() async {
    if (_isClosing) return;
    _isClosing = true;

    _debounce?.cancel();

    try {
      if (_sp.getBool(SPKeys.saveWindowSize) ?? false) {
        final isMaximized = _sp.getBool(SPKeys.windowMaximized) ?? false;
        final isFullscreen = _sp.getBool(SPKeys.windowFullscreen) ?? false;
        if (!isMaximized && !isFullscreen) {
          try {
            final size = await _windowManager.getSize();
            if (size.width > 0 && size.height > 0) {
              await _sp.setInt(SPKeys.windowHeight, size.height.toInt());
              await _sp.setInt(SPKeys.windowWidth, size.width.toInt());
            }
          } catch (_) {}
        }
      }

      await _playerService.shutdown();
    } catch (e, s) {
      Logger.e(e, trace: s, tag: '$WindowSizeToSettingsListener');
    } finally {
      try {
        await _windowManager.destroy();
      } catch (e, s) {
        Logger.e(e, trace: s, tag: '$WindowSizeToSettingsListener');
      }
    }
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

  void dispose() {
    _debounce?.cancel();
    _windowManager.removeListener(this);
  }

  @override
  void onWindowResize() {
    if (_isClosing) return;
    if (isLinux || isWindows) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 5), () {
        if (_isClosing) return;
        _windowManager
            .getSize()
            .then((v) {
              if (_isClosing) return;
              if (_sp.getBool(SPKeys.saveWindowSize) ?? false) {
                _sp
                    .setInt(SPKeys.windowHeight, v.height.toInt())
                    .then(
                      (_) => _sp.setInt(SPKeys.windowWidth, v.width.toInt()),
                    );
              }
            })
            .catchError((e, s) {
              Logger.e(e, trace: s, tag: '$WindowSizeToSettingsListener');
            });
      });
    }
  }

  @override
  void onWindowResized() {
    if (_isClosing) return;
    if (isMacOS) {
      _windowManager
          .getSize()
          .then((v) {
            if (_isClosing) return;
            if (_sp.getBool(SPKeys.saveWindowSize) ?? false) {
              _sp
                  .setInt(SPKeys.windowHeight, v.height.toInt())
                  .then((_) => _sp.setInt(SPKeys.windowWidth, v.width.toInt()));
            }
          })
          .catchError((e, s) {
            Logger.e(e, trace: s, tag: '$WindowSizeToSettingsListener');
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
