import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/theme.dart';
import '../../extensions/taget_platform_x.dart';
import '../../player/player_model.dart';
import '../../settings/settings_model.dart';
import 'desktop_musicpod_app.dart';
import 'mobile_musicpod_app.dart';

class YaruMusicPodApp extends StatelessWidget with WatchItMixin {
  const YaruMusicPodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final useCustomThemeColor = watchPropertyValue(
      (SettingsModel m) => m.useCustomThemeColor,
    );
    final customThemeColor = watchPropertyValue(
      (SettingsModel m) => m.customThemeColor,
    );

    final usePlayerColor = watchPropertyValue(
      (SettingsModel m) => m.usePlayerColor,
    );
    final playerColor = watchPropertyValue((PlayerModel m) => m.color);

    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );

    return YaruTheme(
      builder: (context, yaru, child) {
        final color = playerColor != null && usePlayerColor
            ? playerColor
            : (customThemeColor != null && useCustomThemeColor
                  ? Color(customThemeColor)
                  : yaru.theme?.colorScheme.primary);

        final yaruLightFlavor = color != null
            ? createYaruLightTheme(primaryColor: color)
            : yaru.theme;
        final yaruDarkFlavor = color != null
            ? createYaruDarkTheme(primaryColor: color)
            : yaru.darkTheme;

        return DesktopMusicPodApp(
          highContrastTheme: yaruHighContrastLight,
          highContrastDarkTheme: yaruHighContrastDark,
          accent: color,
          lightTheme: useYaruTheme
              ? yaruLightWithTweaks(yaruLightFlavor)
              : null,
          darkTheme: useYaruTheme ? yaruDarkWithTweaks(yaruDarkFlavor) : null,
        );
      },
    );
  }
}

class MaterialMusicPodApp extends StatelessWidget with WatchItMixin {
  const MaterialMusicPodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final useCustomThemeColor = watchPropertyValue(
      (SettingsModel m) => m.useCustomThemeColor,
    );
    final customThemeColor = watchPropertyValue(
      (SettingsModel m) => m.customThemeColor,
    );

    final usePlayerColor = watchPropertyValue(
      (SettingsModel m) => m.usePlayerColor,
    );
    final playerColor = watchPropertyValue((PlayerModel m) => m.color);

    return SystemThemeBuilder(
      builder: (context, accent) {
        final color = playerColor != null && usePlayerColor
            ? playerColor
            : (customThemeColor != null && useCustomThemeColor
                  ? Color(customThemeColor)
                  : accent.accent);

        return isMobile
            ? MobileMusicPodApp(accent: color)
            : DesktopMusicPodApp(accent: color);
      },
    );
  }
}
