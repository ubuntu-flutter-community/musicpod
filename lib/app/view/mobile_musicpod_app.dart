import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:phoenix_theme/phoenix_theme.dart';

import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/app_localizations.dart';
import '../../local_audio/local_audio_manager.dart';
import '../../player/player_manager.dart';
import '../../podcasts/podcast_manager.dart';
import '../../radio/radio_manager.dart';
import '../../settings/settings_manager.dart';
import '../app_config.dart';
import '../page_ids.dart';
import '../routing_manager.dart';
import 'create_master_items.dart';
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

    final phoenix = phoenixTheme(color: widget.accent ?? kMusicPodDefaultColor);
    final routingManager = di<RoutingManager>();

    final phoenixLightWithFont = isLinux
        ? phoenix.lightTheme
        : applyChineseFontToPhoenixTheme(
            lightTheme: phoenix.lightTheme,
            darkTheme: phoenix.darkTheme,
          );
    final phoenixDarkWithFont = isLinux
        ? phoenix.darkTheme
        : applyChineseFontToPhoenixDarkTheme(darkTheme: phoenix.darkTheme);

    return MaterialApp(
      navigatorKey: routingManager.masterNavigatorKey,
      navigatorObservers: [routingManager],
      initialRoute: routingManager.selectedPageId ?? PageIDs.searchPage,
      onGenerateRoute: (settings) {
        final masterItems = getAllMasterItems(
          context,
          di<PodcastManager>(),
          di<LocalAudioManager>(),
          di<RadioManager>(),
        );
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
      theme: phoenixLightWithFont,
      darkTheme: phoenixDarkWithFont.copyWith(
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
