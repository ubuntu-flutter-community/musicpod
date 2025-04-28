import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

enum CustomThemeMode { system, dark, light, custom }

extension ThemeModeX on ThemeMode {
  String localize(AppLocalizations l10n) => switch (this) {
        ThemeMode.system => l10n.system,
        ThemeMode.dark => l10n.dark,
        ThemeMode.light => l10n.light,
        _ => 'Custom'
      };
      
  CustomThemeMode toCustomMode() => switch (this) {
        ThemeMode.system => CustomThemeMode.system,
        ThemeMode.dark => CustomThemeMode.dark,
        ThemeMode.light => CustomThemeMode.light,
        _ => CustomThemeMode.custom
      };

  String get stringRepresentation => switch (this) {
    ThemeMode.system => '自动',
    ThemeMode.light => '亮色',
    ThemeMode.dark => '暗色',
  };

  IconData get icon => switch (this) {
    ThemeMode.system => Icons.brightness_auto,
    ThemeMode.light => Icons.brightness_high,
    ThemeMode.dark => Icons.brightness_2,
  };
}

// 自定义枚举转换为ThemeMode
extension CustomThemeModeX on CustomThemeMode {
  ThemeMode toThemeMode() => switch (this) {
        CustomThemeMode.system => ThemeMode.system,
        CustomThemeMode.dark => ThemeMode.dark,
        CustomThemeMode.light => ThemeMode.light,
        CustomThemeMode.custom => ThemeMode.light
      };
}
