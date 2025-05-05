import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/yaru.dart' show YaruWindowTitleBar;

import 'app/view/musicpod.dart';
import 'extensions/taget_platform_x.dart';
import 'register.dart';

Future<void> main(List<String> args) async {
  if (isMobile) {
    WidgetsFlutterBinding.ensureInitialized();
  } else {
    // Note: this includes the `WidgetsFlutterBinding.ensureInitialized()` call
    await YaruWindowTitleBar.ensureInitialized();
    WindowManager.instance
      ..setMinimumSize(const Size(500, 700))
      ..setSize(const Size(950, 820));
  }

  if (isWindows) {
    await SystemTheme.accentColor.load();
  }

  MediaKit.ensureInitialized();

  registerDependencies(args: args);

  runApp(const MusicPod());
}
