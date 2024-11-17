import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/yaru.dart';

import 'app/view/app.dart';
import 'app_config.dart';
import 'constants.dart';
import 'persistence_utils.dart';
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
  if (!yaruStyled) {
    SystemTheme.fallbackColor = kMusicPodFallBackColor;
    await SystemTheme.accentColor.load();
  }

  MediaKit.ensureInitialized();

  await registerDependencies(
    args: args,
    downloadsDefaultDir: await getDownloadsDefaultDir(),
  );

  runApp(
    isGtkApp
        ? const GtkApplication(child: YaruMusicPodApp())
        : const MaterialMusicPodApp(),
  );
}
