import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:yaru/yaru.dart' show YaruWindowTitleBar;

import 'app/view/musicpod.dart';
import 'common/logging.dart';
import 'extensions/platform_x.dart';

Future<void> main(List<String> args) async {
  if (isMobile) {
    WidgetsFlutterBinding.ensureInitialized();
  } else {
    await YaruWindowTitleBar.ensureInitialized();
  }

  PaintingBinding.instance.imageCache.maximumSizeBytes = 40 * 1024 * 1024;
  PaintingBinding.instance.imageCache.maximumSize = 100;

  FlutterError.onError = Logger.fe;

  if (isWindows) {
    await SystemTheme.accentColor.load();
  }

  runApp(const MusicPod());
}
