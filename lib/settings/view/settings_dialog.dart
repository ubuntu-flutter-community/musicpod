import 'package:flutter/material.dart';

import '../../common/view/global_keys.dart';
import 'about_page.dart';
import 'licenses_page.dart';
import 'settings_page.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Navigator(
      // ignore: deprecated_member_use
      onPopPage: (route, result) => route.didPop(result),
      key: settingsNavigatorKey,
      initialRoute: '/settings',
      onGenerateRoute: (settings) {
        Widget page = switch (settings.name) {
          '/about' => const AboutPage(),
          '/licenses' => const LicensesPage(),
          _ => const SettingsPage()
        };

        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 500),
        );
      },
    );

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(height: 800, width: 600, child: nav),
    );
  }
}
