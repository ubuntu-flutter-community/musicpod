import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:yaru/yaru.dart';

import '../l10n/l10n.dart';
import 'app.dart';

class MusicPod extends StatelessWidget {
  const MusicPod({super.key, required this.yaruApp});

  final bool yaruApp;

  @override
  Widget build(BuildContext context) {
    if (yaruApp) {
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
        _m3Theme(),
        _m3Theme(brightness: Brightness.dark),
      );
    }
  }

  ThemeData _m3Theme({
    Brightness brightness = Brightness.light,
    Color color = Colors.greenAccent,
  }) {
    final dividerColor = brightness == Brightness.light
        ? const Color.fromARGB(48, 0, 0, 0)
        : const Color.fromARGB(18, 255, 255, 255);
    return ThemeData(
      useMaterial3: true,
      dividerColor: dividerColor,
      dividerTheme: DividerThemeData(
        color: dividerColor,
        space: 1.0,
        thickness: 0.0,
      ),
      colorScheme: ColorScheme.fromSeed(
        surfaceTint: Colors.transparent,
        seedColor: color,
        brightness: brightness,
      ),
    );
  }

  MaterialApp _app(ThemeData? lightTheme, ThemeData? darkTheme) {
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
