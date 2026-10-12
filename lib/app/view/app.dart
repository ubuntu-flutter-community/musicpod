import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:system_theme/system_theme.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/theme.dart';
import '../../extensions/platform_x.dart';
import '../../player/manager/player_manager.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import 'desktop_musicpod_app.dart';
import 'mobile_musicpod_app.dart';

class YaruMusicPodApp extends StatelessWidget with WatchItMixin {
  const YaruMusicPodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final playerColor = watchPropertyValue((PlayerManager m) => m.color);

    return Consumer(
      builder: (context, ref, _) {
        final useCustomThemeColor =
            ref.watch(
              settingsBoolManagerProvider(SPKeys.useCustomThemeColor),
            ) ??
            false;
        final customThemeColor = ref.watch(
          settingsIntManagerProvider(SPKeys.customThemeColor),
        );

        final usePlayerColor =
            ref.watch(settingsBoolManagerProvider(SPKeys.usePlayerColor)) ??
            true;

        final useYaruTheme =
            ref.watch(settingsBoolManagerProvider(SPKeys.useYaruTheme)) ??
            isLinux;

        return YaruTheme(
          builder: (context, yaru, child) {
            final color = playerColor != null && usePlayerColor
                ? playerColor
                : (customThemeColor != null && useCustomThemeColor
                      ? Color(customThemeColor)
                      : null);

            final yaruLightFlavor = color == null
                ? yaru.theme
                : createYaruLightTheme(primaryColor: color);
            final yaruDarkFlavor = color == null
                ? yaru.darkTheme
                : createYaruDarkTheme(primaryColor: color);

            return DesktopMusicPodApp(
              highContrastTheme: yaruHighContrastLight,
              highContrastDarkTheme: yaruHighContrastDark,
              accent: color,
              lightTheme: useYaruTheme
                  ? yaruLightWithTweaks(yaruLightFlavor)
                  : null,
              darkTheme: useYaruTheme
                  ? yaruDarkWithTweaks(yaruDarkFlavor)
                  : null,
            );
          },
        );
      },
    );
  }
}

class MaterialMusicPodApp extends StatelessWidget with WatchItMixin {
  const MaterialMusicPodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final playerColor = watchPropertyValue((PlayerManager m) => m.color);

    return Consumer(
      builder: (context, ref, _) {
        final useCustomThemeColor =
            ref.watch(
              settingsBoolManagerProvider(SPKeys.useCustomThemeColor),
            ) ??
            false;
        final customThemeColor = ref.watch(
          settingsIntManagerProvider(SPKeys.customThemeColor),
        );

        final usePlayerColor =
            ref.watch(settingsBoolManagerProvider(SPKeys.usePlayerColor)) ??
            true;

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
      },
    );
  }
}
