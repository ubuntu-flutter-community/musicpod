import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../library.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';
import 'app.dart';

class YaruMusicPodApp extends StatelessWidget {
  const YaruMusicPodApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) {
        return MusicPodApp(
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
      child: const MusicPodApp(),
    );
  }
}

class MusicPodApp extends StatefulWidget {
  const MusicPodApp({
    super.key,
    this.lightTheme,
    this.darkTheme,
  });

  final ThemeData? lightTheme, darkTheme;

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: widget.lightTheme ?? m3Theme(),
      darkTheme: widget.darkTheme ?? m3Theme(brightness: Brightness.dark),
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
  }
}
