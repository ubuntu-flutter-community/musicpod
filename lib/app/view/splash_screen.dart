import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: isLinux
        ? yaruLight
        : phoenixTheme(color: kMusicPodDefaultColor).lightTheme,
    darkTheme: isLinux
        ? yaruDark
        : phoenixTheme(color: kMusicPodDefaultColor).darkTheme,
    title: '',
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: supportedLocales,
    home: Scaffold(
      appBar: const YaruWindowTitleBar(
        border: BorderSide.none,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icon.png', height: 250, width: 250),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: isLinux
                      ? const YaruCircularProgressIndicator()
                      : const CircularProgressIndicator.adaptive(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
