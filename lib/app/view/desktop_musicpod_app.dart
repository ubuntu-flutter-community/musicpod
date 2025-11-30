import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../settings/settings_model.dart';
import 'desktop_home_page.dart';
import 'mouse_and_keyboard_command_wrapper.dart';

class DesktopMusicPodApp extends StatelessWidget with WatchItMixin {
  const DesktopMusicPodApp({
    super.key,
    this.lightTheme,
    this.darkTheme,
    this.accent,
    this.highContrastTheme,
    this.highContrastDarkTheme,
  });

  final ThemeData? lightTheme,
      darkTheme,
      highContrastTheme,
      highContrastDarkTheme;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );
    final color = accent ?? kMusicPodDefaultColor;
    final phoenix = phoenixTheme(color: color);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.values[themeIndex],
      highContrastTheme: highContrastTheme,
      highContrastDarkTheme: highContrastDarkTheme,
      theme:
          lightTheme ??
          (useYaruTheme
              ? yaruLightWithTweaks(createYaruLightTheme(primaryColor: color))
              : phoenix.lightTheme),
      darkTheme:
          darkTheme ??
          (useYaruTheme
              ? yaruDarkWithTweaks(createYaruDarkTheme(primaryColor: color))
              : phoenix.darkTheme),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      onGenerateTitle: (context) => AppConfig.appTitle,
      home: const MouseAndKeyboardCommandWrapper(child: DesktopHomePage()),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
          PointerDeviceKind.trackpad,
        },
      ),
    );
  }
}
