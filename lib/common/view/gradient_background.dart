import 'package:flutter/material.dart';

/// 渐变背景组件
/// 
/// 为应用添加渐变背景效果，可应用于任何组件
class GradientBackground extends StatelessWidget {
  /// 创建一个渐变背景
  /// 
  /// [colors] 渐变使用的颜色列表，至少需要2种颜色
  /// [child] 子组件
  /// [begin] 渐变开始位置
  /// [end] 渐变结束位置
  /// [opacity] 渐变透明度
  const GradientBackground({
    super.key,
    required this.colors,
    required this.child,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.opacity = 0.15,
  }) : assert(colors.length >= 1, '颜色列表至少需要一种颜色');

  /// 渐变颜色列表
  final List<Color> colors;
  
  /// 子组件
  final Widget child;
  
  /// 渐变开始位置
  final AlignmentGeometry begin;
  
  /// 渐变结束位置
  final AlignmentGeometry end;
  
  /// 渐变透明度
  final double opacity;

  @override
  Widget build(BuildContext context) {
    // 如果只有一种颜色，则使用单色背景
    if (colors.length == 1) {
      final alpha = (opacity * 255).toInt(); // 转换为int
      return ColoredBox(
        color: colors.first.withAlpha(alpha), // 使用withAlpha替代withValues和withOpacity
        child: child,
      );
    }
    
    // 否则使用渐变背景
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.map((e) {
            final alpha = (opacity * 255).toInt(); // 转换为int
            return e.withAlpha(alpha); // 使用withAlpha替代withValues和withOpacity
          }).toList(),
          begin: begin,
          end: end,
        ),
      ),
      child: child,
    );
  }
}

/// 创建一个将渐变背景应用到某个Material组件的包装器
class GradientScaffold extends StatelessWidget {
  /// 创建一个带渐变背景的Scaffold
  const GradientScaffold({
    super.key,
    required this.colors,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.opacity = 0.1,
  });

  /// 渐变颜色列表
  final List<Color> colors;
  
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
  
  /// 渐变开始位置
  final AlignmentGeometry begin;
  
  /// 渐变结束位置
  final AlignmentGeometry end;
  
  /// 渐变透明度
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 将背景色设为透明，以便显示渐变效果
      backgroundColor: Colors.transparent,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      // 包装内容于渐变背景中
      body: GradientBackground(
        colors: colors,
        begin: begin,
        end: end,
        opacity: opacity,
        child: body,
      ),
    );
  }
}

/// 为整个应用添加渐变背景的包装器
class GradientAppWrapper extends StatelessWidget {
  /// 创建一个可以为整个应用添加渐变背景的包装器
  /// 
  /// 这个组件会保持应用原有的结构，只在顶层添加一个渐变层
  const GradientAppWrapper({
    super.key,
    required this.colors,
    required this.child,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.opacity = 0.15,
  });

  /// 渐变颜色列表
  final List<Color> colors;
  
  /// 子应用
  final Widget child;
  
  /// 渐变开始位置
  final AlignmentGeometry begin;
  
  /// 渐变结束位置
  final AlignmentGeometry end;
  
  /// 渐变透明度
  final double opacity;

  @override
  Widget build(BuildContext context) {
    // 使用Stack布局，在底层放置渐变背景，顶层放置应用内容
    
    // 渐变颜色列表，确保至少有两种颜色
    final gradientColors = colors.length < 2 
        ? [
            colors.first, 
            Color.fromARGB(
              colors.first.a.toInt(), // 使用原始属性，避免类型转换问题
              colors.first.r.toInt(), 
              colors.first.g.toInt(), 
              (colors.first.b.toInt() + 50) % 256,
            ),
          ] 
        : colors;
    
    return Stack(
      children: [
        // 渐变背景层
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors.map((e) {
                  final alpha = (opacity * 255).toInt(); // 转换为int
                  return e.withAlpha(alpha); // 使用withAlpha替代withValues和withOpacity
                }).toList(),
                begin: begin,
                end: end,
              ),
            ),
          ),
        ),
        // 应用内容层
        child,
      ],
    );
  }
} 