import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:system_theme/system_theme.dart';
import 'package:yaru/yaru.dart' show YaruWindowTitleBar;

import 'app/view/musicpod.dart';
import 'extensions/taget_platform_x.dart';
import 'register.dart';

Future<void> main(List<String> args) async {
  if (isMobile) {
    WidgetsFlutterBinding.ensureInitialized();
  } else {
    await YaruWindowTitleBar.ensureInitialized();
  }

  if (isWindows) {
    await SystemTheme.accentColor.load();
  }

  MediaKit.ensureInitialized();

  registerDependencies(args: args);

  runApp(const MusicPod());
}
