import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../common.dart';
import '../../external_path.dart';
import '../../get.dart';
import '../../library.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';
import '../settings/settings_model.dart';
import 'view/scaffold.dart';

class YaruMusicPodApp extends StatelessWidget {
  const YaruMusicPodApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) {
        return _MusicPodApp(
          highContrastTheme: yaruHighContrastLight,
          highContrastDarkTheme: yaruHighContrastDark,
          lightTheme: yaru.theme?.copyWith(
            actionIconTheme: ActionIconThemeData(
              backButtonIconBuilder: (context) => Icon(Iconz().goBack),
            ),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              actionTextColor: yaru.theme?.colorScheme.primary,
            ),
            cardColor: yaru.theme?.dividerColor.scale(
              lightness: -0.01,
            ),
          ),
          darkTheme: yaru.darkTheme?.copyWith(
            actionIconTheme: ActionIconThemeData(
              backButtonIconBuilder: (context) => Icon(Iconz().goBack),
            ),
            scaffoldBackgroundColor: const Color(0xFF1e1e1e),
            dividerColor: darkDividerColor,
            dividerTheme: const DividerThemeData(
              color: darkDividerColor,
              space: 1.0,
              thickness: 0.0,
            ),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              actionTextColor: yaru.theme?.colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}

class MaterialMusicPodApp extends StatelessWidget {
  const MaterialMusicPodApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SystemThemeBuilder(
      builder: (context, accent) {
        return _MusicPodApp(
          accent: accent.accent,
        );
      },
    );
  }
}

class _MusicPodApp extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _MusicPodApp({
    // ignore: unused_element
    super.key,
    this.lightTheme,
    this.darkTheme,
    this.accent,
    this.highContrastTheme,
    this.highContrastDarkTheme,
  });

  final ThemeData? lightTheme,
      darkTheme,
      highContrastTheme,
      highContrastDarkTheme;
  final Color? accent;

  @override
  State<_MusicPodApp> createState() => _MusicPodAppState();
}

class _MusicPodAppState extends State<_MusicPodApp>
    with WidgetsBindingObserver {
  late Future<bool> _initFuture;

  Future<bool> _init() async {
    WidgetsBinding.instance.addObserver(this);
    if (!isMobile) {
      YaruWindow.of(context).onClose(
        () async {
          await getIt.reset();
          return true;
        },
      );
    }

    final appModel = getIt<AppModel>();
    await getIt<LibraryModel>().init();

    if (!mounted) return false;
    await appModel.init();

    getIt<ExternalPathService>().init();

    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await getIt.reset();
    }
  }

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  @override
  Widget build(BuildContext context) {
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.values[themeIndex],
      highContrastTheme: widget.highContrastTheme,
      highContrastDarkTheme: widget.highContrastDarkTheme,
      theme: widget.lightTheme ??
          m3Theme(color: widget.accent ?? Colors.greenAccent),
      darkTheme: widget.darkTheme ??
          m3Theme(
            brightness: Brightness.dark,
            color: widget.accent ?? Colors.greenAccent,
          ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      onGenerateTitle: (context) => 'MusicPod',
      home: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          return snapshot.data == true
              ? const MusicPodScaffold()
              : const SplashScreen();
        },
      ),
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
