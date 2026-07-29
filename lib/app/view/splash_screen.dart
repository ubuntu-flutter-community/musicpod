import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../l10n/app_localizations.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.body});

  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isLinux
          ? createYaruLightTheme(primaryColor: kMusicPodDefaultColor)
          : lightBaseTheme(kMusicPodDefaultColor),
      darkTheme: isLinux
          ? createYaruDarkTheme(primaryColor: kMusicPodDefaultColor)
          : lightDarkTheme(kMusicPodDefaultColor),
      title: '',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      home: Scaffold(
        appBar: const YaruWindowTitleBar(
          border: BorderSide.none,
          backgroundColor: Colors.transparent,
        ),
        body:
            body ??
            Center(
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
}
