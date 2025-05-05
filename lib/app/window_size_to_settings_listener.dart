import 'dart:ui';

import 'package:window_manager/window_manager.dart';

class WindowSizeToSettingsListener implements WindowListener {
  WindowSizeToSettingsListener({
    required Future<void> Function(Size value) onResize,
    required Future<void> Function(bool value) onMaximize,
    required Future<void> Function(bool value) onFullscreen,
  })  : _onResize = onResize,
        _onMaximize = onMaximize,
        _onFullscreen = onFullscreen;

  final Future<void> Function(Size value) _onResize;
  final Future<void> Function(bool value) _onMaximize;
  final Future<void> Function(bool value) _onFullscreen;

  @override
  void onWindowBlur() {}

  @override
  void onWindowClose() {}

  @override
  void onWindowDocked() {}

  @override
  void onWindowEnterFullScreen() => _onFullscreen(true);

  @override
  void onWindowEvent(String eventName) {}

  @override
  void onWindowFocus() {}

  @override
  void onWindowLeaveFullScreen() => _onFullscreen(false);

  @override
  void onWindowMaximize() => _onMaximize(true);

  @override
  void onWindowMinimize() {}

  @override
  void onWindowMove() {}

  @override
  void onWindowMoved() {}

  @override
  void onWindowResize() {}

  @override
  void onWindowResized() => WindowManager.instance.getSize().then(_onResize);

  @override
  void onWindowRestore() {}

  @override
  void onWindowUndocked() {}

  @override
  void onWindowUnmaximize() => _onMaximize(false);
}
