import 'package:flutter/material.dart' hide LicensePage;

import '../../globals.dart';
import 'about_page.dart';
import 'license_page.dart';
import 'settings_page.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Navigator(
      onPopPage: (route, result) => route.didPop(result),
      key: settingsNavigatorKey,
      initialRoute: '/settings',
      onGenerateRoute: (settings) {
        Widget page = switch (settings.name) {
          '/settings' => const SettingsPage(),
          '/about' => const AboutPage(),
          '/licenses' => const LicensePage(),
          _ => const SettingsPage()
        };

        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 500),
        );
      },
    );

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.background,
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(height: 800, width: 600, child: nav),
    );
  }
}
