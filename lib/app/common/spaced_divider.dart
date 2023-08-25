import 'package:flutter/material.dart';

class SpacedDivider extends StatelessWidget {
  const SpacedDivider({
    super.key,
    this.top = 10,
    this.bottom = 20,
    this.left = 20,
    this.right = 20,
  });

  final double top, bottom, left, right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        right: right,
        top: top,
        bottom: bottom,
      ),
      child: const Divider(),
    );
  }
}
