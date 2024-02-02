import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../library.dart';
import '../../theme.dart';
import '../globals.dart';
import '../l10n/l10n.dart';
import 'app.dart';

class YaruMusicPodApp extends StatelessWidget {
  const YaruMusicPodApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return YaruTheme(
          builder: (context, yaru, child) {
            return MusicPodApp(
              themeMode: currentMode,
              lightTheme: yaru.theme,
              darkTheme: yaru.darkTheme?.copyWith(
                scaffoldBackgroundColor: const Color(0xFF1e1e1e),
                dividerColor: darkDividerColor,
                dividerTheme: const DividerThemeData(
                  color: darkDividerColor,
                  space: 1.0,
                  thickness: 0.0,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MaterialMusicPodApp extends StatelessWidget {
  const MaterialMusicPodApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return SystemThemeBuilder(
          builder: (context, accent) {
            return MusicPodApp(
              themeMode: currentMode,
              accent: accent.accent,
            );
          },
        );
      },
    );
  }
}

class MusicPodApp extends StatefulWidget {
  const MusicPodApp({
    super.key,
    this.lightTheme,
    this.darkTheme,
    this.accent,
    required this.themeMode,
  });

  final ThemeData? lightTheme, darkTheme;
  final ThemeMode? themeMode;
  final Color? accent;

  @override
  State<MusicPodApp> createState() => _MusicPodAppState();
}

class _MusicPodAppState extends State<MusicPodApp> {
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    getService<LibraryService>().init().then(
      (value) {
        if (!initialized) {
          setState(() => initialized = value);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SystemThemeBuilder(
      builder: (context, accent) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: widget.themeMode,
          theme: widget.lightTheme ??
              m3Theme(color: widget.accent ?? Colors.greenAccent),
          darkTheme: widget.darkTheme ??
              m3Theme(
                brightness: Brightness.dark,
                color: widget.accent ?? Colors.greenAccent,
              ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedLocales,
          onGenerateTitle: (context) => 'MusicPod',
          home: initialized ? App.create() : const SplashScreen(),
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
      },
    );
  }
}
