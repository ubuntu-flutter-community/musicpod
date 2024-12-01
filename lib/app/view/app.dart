import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/theme.dart';
import 'desktop_musicpod_app.dart';
import 'mobile_musicpod_app.dart';

class YaruMusicPodApp extends StatelessWidget {
  const YaruMusicPodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) => DesktopMusicPodApp(
        highContrastTheme: yaruHighContrastLight,
        highContrastDarkTheme: yaruHighContrastDark,
        lightTheme: yaruLightWithTweaks(yaru),
        darkTheme: yaruDarkWithTweaks(yaru),
      ),
    );
  }
}

class MaterialMusicPodApp extends StatelessWidget {
  const MaterialMusicPodApp({super.key});

  @override
  Widget build(BuildContext context) => SystemThemeBuilder(
        builder: (context, accent) {
          return isMobile
              ? MobileMusicPodApp(accent: accent.accent)
              : DesktopMusicPodApp(accent: accent.accent);
        },
      );
}
