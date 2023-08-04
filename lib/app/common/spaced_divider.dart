import 'package:flutter/material.dart';

class SpacedDivider extends StatelessWidget {
  const SpacedDivider({
    super.key,
    this.top = 10,
    this.bottom = 20,
  });

  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: top,
        bottom: bottom,
      ),
      child: const Divider(
        height: 0,
      ),
    );
  }
}
