import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
import '../../common/page_ids.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../settings/settings_model.dart';
import 'create_master_items.dart';
import 'mobile_page.dart';

class MobileMusicPodApp extends StatelessWidget with WatchItMixin {
  const MobileMusicPodApp({super.key, this.accent});

  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    final phoenix = phoenixTheme(color: accent ?? Colors.greenAccent);

    final libraryModel = watchIt<LibraryModel>();
    final masterItems = createMasterItems();
    watchPropertyValue((LibraryModel m) => m.playlistsLength);
    watchPropertyValue((LibraryModel m) => m.starredStationsLength);
    watchPropertyValue((LibraryModel m) => m.favoriteAlbumsLength);
    watchPropertyValue((LibraryModel m) => m.podcastsLength);

    return MaterialApp(
      navigatorKey: libraryModel.masterNavigatorKey,
      navigatorObservers: [libraryModel],
      initialRoute: AppConfig.isMobilePlatform
          ? (libraryModel.selectedPageId ?? PageIDs.homePage)
          : null,
      onGenerateRoute: (settings) {
        final page = (masterItems.firstWhereOrNull(
                  (e) => e.pageId == settings.name,
                ) ??
                masterItems.elementAt(0))
            .pageBuilder(context);

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => MobilePage(page: page),
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
