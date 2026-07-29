import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../l10n/app_localizations.dart';
import '../../settings/manager/settings_manager.dart';
import '../app_config.dart';
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
    final themeIndex = watchPropertyValue((SettingsManager m) => m.themeIndex);
    final useYaruTheme = watchPropertyValue(
      (SettingsManager m) => m.useYaruTheme,
    );
    final color = accent ?? kMusicPodDefaultColor;

    final theTheme =
        lightTheme ??
        (useYaruTheme
            ? yaruLightWithTweaks(createYaruLightTheme(primaryColor: color))
            : isLinux
            ? lightBaseTheme(color)
            : applyChineseFontToTheme(theme: lightBaseTheme(color)));
    final theDarkTheme =
        darkTheme ??
        (useYaruTheme
            ? yaruDarkWithTweaks(createYaruDarkTheme(primaryColor: color))
            : isLinux
            ? lightDarkTheme(color)
            : applyChineseFontToTheme(theme: lightDarkTheme(color)));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.values[themeIndex],
      highContrastTheme: highContrastTheme,
      highContrastDarkTheme: highContrastDarkTheme,
      // TODO: pin down why we need to apply the emoji font on Linux, and if we can do it in a cleaner way
      // because this causes heavy lags if used on Windows and MacOS
      theme: isLinux
          ? theTheme?.copyWith(textTheme: textThemeWithEmojis(theTheme))
          : theTheme,
      darkTheme: isLinux
          ? theDarkTheme?.copyWith(textTheme: textThemeWithEmojis(theDarkTheme))
          : theDarkTheme,
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
