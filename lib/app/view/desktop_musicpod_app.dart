import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../l10n/l10n.dart';
import '../../settings/settings_model.dart';
import 'back_button_wrapper.dart';
import 'desktop_home_page.dart';

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
    final color = accent ?? const Color(0xFFed3c63);
    final phoenix = phoenixTheme(color: color);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.values[themeIndex],
      highContrastTheme: highContrastTheme,
      highContrastDarkTheme: highContrastDarkTheme,
      theme: lightTheme ??
          (AppConfig.yaruStyled
              ? createYaruLightTheme(primaryColor: color)
              : phoenix.lightTheme),
      darkTheme: darkTheme ??
          (AppConfig.yaruStyled
              ? createYaruDarkTheme(primaryColor: color)
              : phoenix.darkTheme),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      onGenerateTitle: (context) => AppConfig.appTitle,
      home: const MouseBackButtonWrapper(child: DesktopHomePage()),
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
