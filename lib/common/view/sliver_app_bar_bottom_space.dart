import 'package:flutter/material.dart';

class SliverAppBarBottomSpace extends StatelessWidget
    implements PreferredSizeWidget {
  const SliverAppBarBottomSpace({super.key, this.size = const Size(0, 10)});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  @override
  Size get preferredSize => size;
}
