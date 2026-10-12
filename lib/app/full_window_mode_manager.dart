import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../extensions/platform_x.dart';

part 'full_window_mode_manager.g.dart';

@Riverpod(keepAlive: true)
class FullWindowModeManager extends _$FullWindowModeManager {
  @override
  bool build() => false;

  Future<void> setFullWindowMode(bool? value) async {
    if (value == null) return;
    state = value;

    if (isMobile) {
      if (state) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        await SystemChrome.setPreferredOrientations([]);
      }
    }
  }

  Future<void> toggleFullWindowMode() => setFullWindowMode(!state);
}
