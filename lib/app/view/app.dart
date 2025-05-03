import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/theme.dart';
import '../../settings/settings_model.dart';
import 'desktop_musicpod_app.dart';
import 'mobile_musicpod_app.dart';

class YaruMusicPodApp extends StatelessWidget with WatchItMixin {
  const YaruMusicPodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final useCustomThemeColor =
        watchPropertyValue((SettingsModel m) => m.useCustomThemeColor);
    final customThemeColor = watchPropertyValue(
      (SettingsModel m) => m.customThemeColor,
    );
    final useYaruTheme =
        watchPropertyValue((SettingsModel m) => m.useYaruTheme);

    return YaruTheme(
      builder: (context, yaru, child) {
        final yaruLightFlavor = useCustomThemeColor && customThemeColor != null
            ? createYaruLightTheme(primaryColor: Color(customThemeColor))
            : yaru.theme;
        final yaruDarkFlavor = useCustomThemeColor && customThemeColor != null
            ? createYaruDarkTheme(primaryColor: Color(customThemeColor))
            : yaru.darkTheme;

        return DesktopMusicPodApp(
          highContrastTheme: yaruHighContrastLight,
          highContrastDarkTheme: yaruHighContrastDark,
          accent: customThemeColor != null && useCustomThemeColor
              ? Color(customThemeColor)
              : yaru.theme?.colorScheme.primary,
          lightTheme:
              useYaruTheme ? yaruLightWithTweaks(yaruLightFlavor) : null,
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
    final useCustomThemeColor =
        watchPropertyValue((SettingsModel m) => m.useCustomThemeColor);
    final customThemeColor = watchPropertyValue(
      (SettingsModel m) => m.customThemeColor,
    );

    return SystemThemeBuilder(
      builder: (context, accent) {
        return isMobile
            ? MobileMusicPodApp(
                accent: customThemeColor != null && useCustomThemeColor
                    ? Color(customThemeColor)
                    : accent.accent,
              )
            : DesktopMusicPodApp(
                accent: customThemeColor != null && useCustomThemeColor
                    ? Color(customThemeColor)
                    : accent.accent,
              );
      },
    );
  }
}
