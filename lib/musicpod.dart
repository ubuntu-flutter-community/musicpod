import 'package:flutter/material.dart';
import 'package:musicpod/app/app.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru/yaru.dart';

class MusicPod extends StatelessWidget {
  const MusicPod({super.key});

  static final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaruThemeData, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: yaruThemeData.theme,
          darkTheme: yaruThemeData.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedLocales,
          onGenerateTitle: (context) => 'MusicPod',
          home: App.create(
            context: context,
            showSnackBar: scaffoldKey.currentState?.showSnackBar,
          ),
          scaffoldMessengerKey: scaffoldKey,
        );
      },
    );
  }
}
