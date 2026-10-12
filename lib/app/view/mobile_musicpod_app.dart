import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../dependencies.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../l10n/app_localizations.dart';
import '../../player/service/player_service.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import '../app_config.dart';
import '../routing_manager.dart';

class MobileMusicPodApp extends ConsumerStatefulWidget {
  const MobileMusicPodApp({super.key, this.accent});

  final Color? accent;

  @override
  ConsumerState<MobileMusicPodApp> createState() => _MobileMusicPodAppState();
}

class _MobileMusicPodAppState extends ConsumerState<MobileMusicPodApp> {
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
      await di<PlayerService>().persistPlayerState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeIndex =
        ref.watch(settingsIntManagerProvider(SPKeys.themeIndex)) ?? 0;

    final light = lightBaseTheme(widget.accent ?? kMusicPodDefaultColor);
    final phoenixLightWithFont = isLinux
        ? light
        : applyChineseFontToTheme(theme: light);
    final dark = lightDarkTheme(widget.accent ?? kMusicPodDefaultColor);
    final phoenixDarkWithFont = isLinux
        ? dark
        : applyChineseFontToTheme(theme: dark);

    return MaterialApp.router(
      routerConfig: ref.watch(routingManagerProvider.notifier).router,
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
