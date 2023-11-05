import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:yaru/yaru.dart';

import '../l10n/l10n.dart';
import 'app.dart';

class MusicPod extends StatelessWidget {
  const MusicPod({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isLinux) {
      return YaruTheme(
        builder: (context, yaruThemeData, child) {
          final materialApp =
              _app(yaruThemeData.theme, yaruThemeData.darkTheme);
          return GtkApplication(
            child: materialApp,
          );
        },
      );
    } else {
      return _app(
        ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        ),
        ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.dark,
          ),
        ),
      );
    }
  }

  MaterialApp _app(ThemeData? lightTheme, ThemeData? darkTheme) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme?.copyWith(
        dividerTheme: const DividerThemeData(
          color: Color.fromARGB(255, 85, 74, 74),
          space: 1.0,
          thickness: 0.0,
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      onGenerateTitle: (context) => 'MusicPod',
      home: App.create(),
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
