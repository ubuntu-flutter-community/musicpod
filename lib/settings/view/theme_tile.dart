import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/ui_constants.dart';

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
        Positioned(
          right: 8,
          top: 5,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                YaruIcons.window_minimize,
                color:
                    themeMode == ThemeMode.dark ? Colors.white : Colors.black,
                size: 15,
              ),
              Icon(
                YaruIcons.window_maximize,
                size: 15,
                color:
                    themeMode == ThemeMode.dark ? Colors.white : Colors.black,
              ),
              Icon(
                YaruIcons.window_close,
                size: 15,
                color:
                    themeMode == ThemeMode.dark ? Colors.white : Colors.black,
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
