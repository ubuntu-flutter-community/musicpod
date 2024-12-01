import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../external_path/external_path_service.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../radio/radio_model.dart';
import '../../settings/settings_model.dart';
import '../connectivity_model.dart';
import 'dart:ui';
import 'master_items.dart';
import 'mobile_page_with_player.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';
import 'splash_screen.dart';

class MobileMusicPodApp extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MobileMusicPodApp({super.key, this.accent});

  final Color? accent;

  @override
  State<MobileMusicPodApp> createState() => _MobileMusicPodAppState();
}

class _MobileMusicPodAppState extends State<MobileMusicPodApp> {
  late Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<bool> _init() async {
    await di<ConnectivityModel>().init();
    await di<LibraryModel>().init();
    await di<RadioModel>().init();
    if (!mounted) return false;
    di<ExternalPathService>().init();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    final phoenix = phoenixTheme(color: widget.accent ?? Colors.greenAccent);

    final libraryModel = watchIt<LibraryModel>();
    final masterItems = createMasterItems(libraryModel: libraryModel);

    return MaterialApp(
      navigatorKey: libraryModel.masterNavigatorKey,
      navigatorObservers: [libraryModel],
      initialRoute:
          isMobile ? (libraryModel.selectedPageId ?? kLocalAudioPageId) : null,
      onGenerateRoute: (settings) {
        final page = (masterItems.firstWhereOrNull(
                  (e) => e.pageId == settings.name,
                ) ??
                masterItems.elementAt(0))
            .pageBuilder(context);

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => FutureBuilder(
            future: _initFuture,
            builder: (context, snapshot) {
              return snapshot.data == true
                  ? MobilePageWithPlayer(page: page)
                  : const SplashScreen();
            },
          ),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
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
      onGenerateTitle: (context) => kAppTitle,
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
