import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

// 添加自定义主题模式枚举
enum CustomThemeMode { system, dark, light, custom }

extension ThemeModeX on ThemeMode {
  String localize(AppLocalizations l10n) => switch (this) {
        ThemeMode.system => l10n.system,
        ThemeMode.dark => l10n.dark,
        ThemeMode.light => l10n.light,
        // 自定义主题使用light字符串，但后续我们会添加本地化
        _ => 'Custom'
      };
      
  // 转换为自定义枚举
  CustomThemeMode toCustomMode() => switch (this) {
        ThemeMode.system => CustomThemeMode.system,
        ThemeMode.dark => CustomThemeMode.dark,
        ThemeMode.light => CustomThemeMode.light,
        _ => CustomThemeMode.custom
      };
}

// 自定义枚举转换为ThemeMode
extension CustomThemeModeX on CustomThemeMode {
  ThemeMode toThemeMode() => switch (this) {
        CustomThemeMode.system => ThemeMode.system,
        CustomThemeMode.dark => ThemeMode.dark,
        CustomThemeMode.light => ThemeMode.light,
        CustomThemeMode.custom => ThemeMode.light // 使用light模式作为基础
      };
}
