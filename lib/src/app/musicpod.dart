import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:system_theme/system_theme.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../common.dart';
import '../../library.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';
import '../settings/settings_model.dart';
import 'app.dart';

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
            cardColor: getCardColor(yaru.theme?.colorScheme),
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
            cardColor: getCardColor(yaru.theme?.colorScheme),
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

class _MusicPodApp extends StatefulWidget {
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

class _MusicPodAppState extends State<_MusicPodApp> {
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    getService<LibraryService>().init().then(
      (value) {
        if (!initialized) {
          setState(() => initialized = value);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final themeIndex = ref
            .watch(settingsModelProvider.select((value) => value.themeIndex));
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
          home: initialized ? const App() : const SplashScreen(),
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
      },
    );
  }
}
