import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../app_config.dart';
import '../page_ids.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../podcasts/podcast_manager.dart';
import '../../local_audio/local_audio_manager.dart';
import '../../player/player_model.dart';
import '../../radio/radio_model.dart';
import '../../settings/settings_model.dart';
import 'create_master_items.dart';
import 'mobile_page.dart';
import '../routing_manager.dart';

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
      await di<PlayerModel>().persistPlayerState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );

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
      initialRoute: routingManager.selectedPageId ?? PageIDs.homePage,
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
      theme: (useYaruTheme && widget.accent != null
          ? yaruLightWithTweaks(
              createYaruLightTheme(primaryColor: widget.accent!),
            )
          : phoenixLightWithFont),
      darkTheme:
          (useYaruTheme && widget.accent != null
                  ? yaruDarkWithTweaks(
                      createYaruDarkTheme(primaryColor: widget.accent!),
                    )
                  : phoenixDarkWithFont)
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
