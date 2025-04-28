import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../settings/settings_model.dart';
import 'gradient_background.dart';

/// 自定义带渐变效果的Scaffold
///
/// 此组件会根据用户的自定义主题设置，自动应用渐变效果
class CustomGradientScaffold extends StatelessWidget with WatchItMixin {
  /// 创建一个可能带有渐变效果的Scaffold
  const CustomGradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
  });

  /// 页面内容
  final Widget body;
  
  /// 应用栏
  final PreferredSizeWidget? appBar;
  
  /// 浮动操作按钮
  final Widget? floatingActionButton;
  
  /// 抽屉菜单
  final Widget? drawer;
  
  /// 右侧抽屉
  final Widget? endDrawer;
  
  /// 底部导航栏
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final themeIndex = watchPropertyValue((SettingsModel m) => m.themeIndex);
    final isCustomTheme = themeIndex == 3; // 索引3表示自定义主题
    
    // 如果不是自定义主题，直接使用普通Scaffold
    if (!isCustomTheme) {
      return Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        drawer: drawer,
        endDrawer: endDrawer,
        bottomNavigationBar: bottomNavigationBar,
      );
    }
    
    // 获取自定义主题设置
    final customColors = watchPropertyValue((SettingsModel m) => m.customThemeColors);
    final useGradient = watchPropertyValue((SettingsModel m) => m.useGradientTheme);
    
    // 如果自定义主题没有启用渐变效果或颜色不足，使用普通Scaffold
    if (!useGradient || customColors.length < 2) {
      return Scaffold(
        appBar: appBar,
        // 单色背景时也添加微弱的颜色
        backgroundColor: customColors.isNotEmpty 
            ? customColors.first.withOpacity(0.05)
            : null,
        body: body,
        floatingActionButton: floatingActionButton,
        drawer: drawer,
        endDrawer: endDrawer,
        bottomNavigationBar: bottomNavigationBar,
      );
    }
    
    // 使用带渐变效果的Scaffold
    return GradientScaffold(
      colors: customColors,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      opacity: 0.12,
    );
  }
} 