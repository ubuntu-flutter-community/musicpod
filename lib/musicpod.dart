import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:musicpod/app/app.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru/yaru.dart';

class MusicPod extends StatelessWidget {
  const MusicPod({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaruThemeData, child) {
        return GtkApplication(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: yaruThemeData.theme,
            darkTheme: yaruThemeData.darkTheme,
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
          ),
        );
      },
    );
  }
}
