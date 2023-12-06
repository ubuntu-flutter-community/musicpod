import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../common.dart';
import '../../library.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';
import 'app.dart';

class MusicPod extends StatelessWidget {
  const MusicPod({super.key});

  @override
  Widget build(BuildContext context) {
    if (yaruStyled) {
      return YaruTheme(
        builder: (context, yaruThemeData, child) {
          return GtkApplication(
            child: MusicPodApp(
              lightTheme: yaruThemeData.theme,
              darkTheme: yaruThemeData.darkTheme
                  ?.copyWith(scaffoldBackgroundColor: const Color(0xFF1e1e1e)),
            ),
          );
        },
      );
    } else {
      return MusicPodApp(
        lightTheme: m3Theme(),
        darkTheme: m3Theme(brightness: Brightness.dark),
      );
    }
  }
}

class MusicPodApp extends StatelessWidget {
  const MusicPodApp({
    super.key,
    this.lightTheme,
    this.darkTheme,
  });

  final ThemeData? lightTheme, darkTheme;

  @override
  Widget build(BuildContext context) {
    const dividerColor = Color.fromARGB(28, 255, 255, 255);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme?.copyWith(
        dividerColor: dividerColor,
        dividerTheme: const DividerThemeData(
          color: dividerColor,
          space: 1.0,
          thickness: 0.0,
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      onGenerateTitle: (context) => 'MusicPod',
      home: FutureBuilder(
        future: getService<LibraryService>().init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return App.create();
          }
          return const Scaffold(appBar: HeaderBar(), body: SplashScreen());
        },
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
