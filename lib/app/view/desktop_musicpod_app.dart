import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../l10n/l10n.dart';
import '../../settings/settings_model.dart';
import '../../common/view/gradient_background.dart';
import 'desktop_home_page.dart';

class DesktopMusicPodApp extends StatelessWidget with WatchItMixin {
  const DesktopMusicPodApp({
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
  Widget build(BuildContext context) {
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    final color = accent ?? const Color(0xFFed3c63);
    final phoenix = phoenixTheme(color: color);

    // 读取自定义主题设置
    final isCustomTheme = themeIndex == 3; // 索引3表示自定义主题
    final customColors =
        watchPropertyValue((SettingsModel m) => m.customThemeColors);
    final useGradient =
        watchPropertyValue((SettingsModel m) => m.useGradientTheme);

    // 创建自定义主题
    ThemeData? customLightTheme;
    if (isCustomTheme && customColors.isNotEmpty) {
      final primaryColor = customColors.first;

      // 创建更明显的自定义主题
      customLightTheme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          // 使用更轻的背景色以便渐变更明显
          surface: Colors.white,
          surfaceContainerHighest: Colors.white.withValues(alpha: 230),
        ),
        // 自定义组件样式
        appBarTheme: AppBarTheme(
          backgroundColor: useGradient && customColors.length > 1
              ? customColors.first.withValues(alpha: 204)
              : primaryColor.withValues(alpha: 204),
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.white, // 设置为白色让渐变更明显
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha: 77),
        ),
        // 设置按钮颜色
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // 创建应用实例
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.values[themeIndex < 3 ? themeIndex : 0],
      highContrastTheme: highContrastTheme,
      highContrastDarkTheme: highContrastDarkTheme,
      theme: isCustomTheme
          ? customLightTheme
          : (lightTheme ??
              (AppConfig.yaruStyled
                  ? createYaruLightTheme(primaryColor: color)
                  : phoenix.lightTheme)),
      darkTheme: darkTheme ??
          (AppConfig.yaruStyled
              ? createYaruDarkTheme(primaryColor: color)
              : phoenix.darkTheme),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      onGenerateTitle: (context) => AppConfig.appTitle,
      home: const DesktopHomePage(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
          PointerDeviceKind.trackpad,
        },
      ),
      builder: (context, child) {
        // 如果是自定义主题且启用了渐变，则应用渐变效果
        if (isCustomTheme && useGradient && customColors.length > 1) {
          return GradientAppWrapper(
            colors: customColors,
            opacity: 0.35, // 增加透明度使渐变更明显
            child: child!,
          );
        }
        return child!;
      },
    );
  }
}
