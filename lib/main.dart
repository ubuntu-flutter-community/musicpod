import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    if (!Platform.isLinux) {
      SystemTheme.fallbackColor = kMusicPodFallBackColor;
      await SystemTheme.accentColor.load();
    }
  }

  MediaKit.ensureInitialized();

  await registerServicesAndViewModels(
    args: args,
    sharedPreferences: await SharedPreferences.getInstance(),
    version: (await PackageInfo.fromPlatform()).version,
    allowDiscordRPC: allowDiscordRPC,
    downloadsDefaultDir: await getDownloadsDefaultDir(),
  );

  runApp(
    Platform.isLinux
        ? const GtkApplication(child: YaruMusicPodApp())
        : const MaterialMusicPodApp(),
  );
}
