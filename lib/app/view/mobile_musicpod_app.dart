import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
import '../../common/page_ids.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../settings/settings_model.dart';
import 'create_master_items.dart';
import 'mobile_page.dart';
import 'routing_manager.dart';

class MobileMusicPodApp extends StatelessWidget with WatchItMixin {
  const MobileMusicPodApp({super.key, this.accent});

  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    final phoenix = phoenixTheme(color: accent ?? kMusicPodDefaultColor);
    final routingManager = di<RoutingManager>();

    return MaterialApp(
      navigatorKey: routingManager.masterNavigatorKey,
      navigatorObservers: [routingManager],
      initialRoute:
          isMobile ? (routingManager.selectedPageId ?? PageIDs.homePage) : null,
      onGenerateRoute: (settings) {
        final masterItems = getAllMasterItems(di<LibraryModel>());
        final page = (masterItems.firstWhereOrNull(
                  (e) => e.pageId == settings.name,
                ) ??
                masterItems.elementAt(0))
            .pageBuilder(context);

        return MaterialPageRoute(
          settings: settings,
          maintainState: false,
          builder: (context) => MobilePage(page: page),
        );
      },
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.values[themeIndex],
      theme: phoenix.lightTheme.copyWith(
        navigationBarTheme: navigationBarTheme(theme: phoenix.lightTheme),
      ),
      darkTheme: phoenix.darkTheme.copyWith(
        navigationBarTheme: navigationBarTheme(theme: phoenix.darkTheme),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      onGenerateTitle: (context) => AppConfig.appTitle,
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
