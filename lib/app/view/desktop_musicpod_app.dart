import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../constants.dart';
import '../../external_path/external_path_service.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../radio/radio_model.dart';
import '../../settings/settings_model.dart';
import '../connectivity_model.dart';
import 'desktop_home_page.dart';
import 'splash_screen.dart';

class DesktopMusicPodApp extends StatefulWidget
    with WatchItStatefulWidgetMixin {
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
  State<DesktopMusicPodApp> createState() => _DesktopMusicPodAppState();
}

class _DesktopMusicPodAppState extends State<DesktopMusicPodApp> {
  late Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<bool> _init() async {
    await di<ConnectivityModel>().init();
    await di<LibraryModel>().init();
    await di<RadioModel>().init();
    if (!mounted) return false;
    di<ExternalPathService>().init();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    final color = widget.accent ?? const Color(0xFFed3c63);
    final phoenix = phoenixTheme(color: color);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.values[themeIndex],
      highContrastTheme: widget.highContrastTheme,
      highContrastDarkTheme: widget.highContrastDarkTheme,
      theme: widget.lightTheme ??
          (yaruStyled
              ? createYaruLightTheme(primaryColor: color)
              : phoenix.lightTheme),
      darkTheme: widget.darkTheme ??
          (yaruStyled
              ? createYaruDarkTheme(primaryColor: color)
              : phoenix.darkTheme),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      onGenerateTitle: (context) => kAppTitle,
      home: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) => snapshot.data == true
            ? const DesktopHomePage()
            : const SplashScreen(),
      ),
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
