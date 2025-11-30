import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../common/page_ids.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/app_localizations.dart';
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
    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );

    final phoenix = phoenixTheme(color: accent ?? kMusicPodDefaultColor);
    final routingManager = di<RoutingManager>();

    return MaterialApp(
      navigatorKey: routingManager.masterNavigatorKey,
      navigatorObservers: [routingManager],
      initialRoute: routingManager.selectedPageId ?? PageIDs.homePage,
      onGenerateRoute: (settings) {
        final masterItems = getAllMasterItems(context, di<LibraryModel>());
        final page =
            (masterItems.firstWhereOrNull((e) => e.pageId == settings.name) ??
                    masterItems.elementAt(0))
                .pageBuilder(context);

        return PageRouteBuilder(
          settings: settings,
          maintainState: false,
          pageBuilder: (_, __, ___) => MobilePage(page: page),
        );
      },
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.values[themeIndex],
      theme: (useYaruTheme && accent != null
          ? yaruLightWithTweaks(createYaruLightTheme(primaryColor: accent!))
          : phoenix.lightTheme),
      darkTheme:
          (useYaruTheme && accent != null
                  ? yaruDarkWithTweaks(
                      createYaruDarkTheme(primaryColor: accent!),
                    )
                  : phoenix.darkTheme)
              ?.copyWith(
                appBarTheme: phoenix.darkTheme.appBarTheme.copyWith(
                  backgroundColor: Colors.black,
                ),
                colorScheme: phoenix.darkTheme.colorScheme.copyWith(
                  surface: Colors.black,
                ),
                scaffoldBackgroundColor: Colors.black,
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
