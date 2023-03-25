import 'dart:ui';

import 'package:flutter/material.dart';

import 'animated_scroll_view_item.dart';

class SingleRowScrollContainer extends StatelessWidget {
  const SingleRowScrollContainer({
    super.key,
    required this.children,
    this.childrenHeight = 250,
    this.childrenWidth = 250,
    this.hPadding = 15,
    this.heightBonus = 10,
  });

  final List<Widget> children;
  final double childrenWidth;
  final double childrenHeight;
  final double hPadding;
  final double heightBonus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: childrenHeight + (2 * hPadding) + heightBonus,
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: ListView.builder(
          itemCount: children.length,
          padding:
              EdgeInsets.symmetric(horizontal: hPadding, vertical: hPadding),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return AnimatedScrollViewItem(
              child: Container(
                padding: EdgeInsets.all(hPadding / 2),
                height: childrenHeight,
                width: childrenWidth,
                child: children[index],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}
