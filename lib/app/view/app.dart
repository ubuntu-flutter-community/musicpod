import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart' hide ColorX;
import 'package:system_theme/system_theme.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../external_path/external_path_service.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../settings/settings_model.dart';
import 'scaffold.dart';
import 'splash_screen.dart';

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
            dividerColor: yaruFixDarkDividerColor,
            dividerTheme: const DividerThemeData(
              color: yaruFixDarkDividerColor,
              space: 1.0,
              thickness: 0.0,
            ),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              actionTextColor: yaru.theme?.colorScheme.primary,
            ),
            cardColor: yaru.darkTheme?.cardColor.scale(
              lightness: 0.05,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFuture = _init();
  }

  Future<bool> _init() async {
    if (!isMobile) {
      YaruWindow.of(context).onClose(
        () async {
          await di.reset();
          return true;
        },
      );
    }

    await di<LibraryModel>().init();
    // Note: if users have small local audio libs this will hardly be visible
    // if users have huge local libs they will probably use MusicPod a lot
    // for local audios and will land here sooner or later.
    // So do this right away to avoid an uninitialized LocalAudioModel
    await di<LocalAudioModel>().init();

    if (!mounted) return false;
    di<ExternalPathService>().init();

    return true;
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      // TODO: correctly safe things we need here, if we need this at all
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    final phoenix = phoenixTheme(color: widget.accent ?? Colors.greenAccent);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.values[themeIndex],
      highContrastTheme: widget.highContrastTheme,
      highContrastDarkTheme: widget.highContrastDarkTheme,
      theme: widget.lightTheme ?? phoenix.lightTheme,
      darkTheme: widget.darkTheme ?? phoenix.darkTheme,
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
