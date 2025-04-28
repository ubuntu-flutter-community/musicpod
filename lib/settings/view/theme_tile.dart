import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/ui_constants.dart';
import '../settings_model.dart';

class ThemeTile extends StatelessWidget {
  const ThemeTile(this.themeMode, {super.key});

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    const height = 100.0;
    const width = 150.0;
    var borderRadius2 = BorderRadius.circular(12);
    var lightContainer = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius2,
      ),
    );
    var darkContainer = Container(
      decoration: BoxDecoration(
        color: YaruColors.coolGrey,
        borderRadius: borderRadius2,
      ),
    );
    var titleBar = Container(
      height: kLargestSpace,
      decoration: BoxDecoration(
        color: themeMode == ThemeMode.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
    );
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Card(
          elevation: 5,
          child: SizedBox(
            height: height,
            width: width,
            child: themeMode == ThemeMode.system
                ? Stack(
                    children: [
                      ClipPath(
                        clipBehavior: Clip.antiAlias,
                        clipper: _CustomClipPathLight(
                          height: height,
                          width: width,
                        ),
                        child: lightContainer,
                      ),
                      ClipPath(
                        clipBehavior: Clip.antiAlias,
                        clipper: _CustomClipPathDark(
                          height: height,
                          width: width,
                        ),
                        child: darkContainer,
                      ),
                      titleBar,
                    ],
                  )
                : (themeMode == ThemeMode.light
                    ? Stack(
                        children: [lightContainer, titleBar],
                      )
                    : Stack(
                        children: [darkContainer, titleBar],
                      )),
          ),
        ),
        const Positioned(
          right: 8,
          top: 5,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                YaruIcons.window_minimize,
                color: Colors.black,
                size: 15,
              ),
              Icon(
                YaruIcons.window_maximize,
                size: 15,
                color: Colors.black,
              ),
              Icon(
                YaruIcons.window_close,
                size: 15,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomClipPathDark extends CustomClipper<Path> {
  _CustomClipPathDark({required this.height, required this.width});

  final double height;
  final double width;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, width);
    path.lineTo(width, height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _CustomClipPathLight extends CustomClipper<Path> {
  _CustomClipPathLight({required this.height, required this.width});

  final double height;
  final double width;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(width, 0);
    path.lineTo(width, height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// 自定义主题预览组件
class CustomThemeTile extends StatelessWidget with WatchItMixin {
  const CustomThemeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = watchPropertyValue((SettingsModel m) => m.customThemeColors);
    final useGradient = watchPropertyValue((SettingsModel m) => m.useGradientTheme);
    
    const height = 100.0;
    const width = 150.0;
    final borderRadius = BorderRadius.circular(12);
    
    // 自定义容器
    final customContainer = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: useGradient && colors.length > 1
            ? LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: useGradient && colors.length > 1 ? null : colors.first,
      ),
    );
    
    final titleBar = Container(
      height: kLargestSpace,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1 * 255),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
    );
    
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Card(
          elevation: 5,
          child: SizedBox(
            height: height,
            width: width,
            child: Stack(
              children: [customContainer, titleBar],
            ),
          ),
        ),
        const Positioned(
          right: 8,
          top: 5,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                YaruIcons.window_minimize,
                color: Colors.black,
                size: 15,
              ),
              Icon(
                YaruIcons.window_maximize,
                size: 15,
                color: Colors.black,
              ),
              Icon(
                YaruIcons.window_close,
                size: 15,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
