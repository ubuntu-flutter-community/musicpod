import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../l10n/app_localizations.dart';
import '../../player/manager/player_manager.dart';
import '../../settings/manager/settings_manager.dart';
import '../app_config.dart';
import '../page_ids.dart';
import '../routing_manager.dart';
import 'master_item_page.dart';
import 'mobile_page.dart';

class MobileMusicPodApp extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MobileMusicPodApp({super.key, this.accent});

  final Color? accent;

  @override
  State<MobileMusicPodApp> createState() => _MobileMusicPodAppState();
}

class _MobileMusicPodAppState extends State<MobileMusicPodApp> {
  late final AppLifecycleListener _listener;
  @override
  void initState() {
    super.initState();

    _listener = AppLifecycleListener(onStateChange: _onStateChanged);
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  Future<void> _onStateChanged(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await di<PlayerManager>().persistPlayerState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeIndex = watchPropertyValue((SettingsManager m) => m.themeIndex);

    final routingManager = di<RoutingManager>();

    final light = lightBaseTheme(widget.accent ?? kMusicPodDefaultColor);
    final phoenixLightWithFont = isLinux
        ? light
        : applyChineseFontToTheme(theme: light);
    final dark = lightDarkTheme(widget.accent ?? kMusicPodDefaultColor);
    final phoenixDarkWithFont = isLinux
        ? dark
        : applyChineseFontToTheme(theme: dark);

    return MaterialApp(
      navigatorKey: routingManager.masterNavigatorKey,
      initialRoute: watchValue((RoutingManager m) => m.selectedPageIdCommand),
      onGenerateRoute: (settings) => PageRouteBuilder(
        settings: settings,
        maintainState: false,
        pageBuilder: (_, __, ___) => MobilePage(
          page: MasterItemPage(pageId: settings.name ?? PageIDs.searchPage),
        ),
      ),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.values[themeIndex],
      theme: phoenixLightWithFont,
      darkTheme: phoenixDarkWithFont.copyWith(
        appBarTheme: dark.appBarTheme.copyWith(backgroundColor: Colors.black),
        colorScheme: dark.colorScheme.copyWith(surface: Colors.black),
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
