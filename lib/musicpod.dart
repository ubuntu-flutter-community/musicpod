import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musicpod/app/app.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru/yaru.dart';

class MusicPod extends StatelessWidget {
  const MusicPod({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaruThemeData, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: yaruThemeData.theme,
          darkTheme: yaruThemeData.darkTheme?.copyWith(
            colorScheme: yaruThemeData.darkTheme?.colorScheme.copyWith(
              background: kBackgroundDark,
              surface: kBackgroundDark,
            ),
            scaffoldBackgroundColor: kBackgroundDark,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedLocales,
          onGenerateTitle: (context) => 'MusicPod',
          home: App.create(
            context: context,
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
      },
    );
  }
}
