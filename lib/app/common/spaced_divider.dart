import 'package:flutter/material.dart';

class SpacedDivider extends StatelessWidget {
  const SpacedDivider({
    super.key,
    this.top = 10,
  });

  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: top,
        bottom: 20,
      ),
      child: const Divider(
        height: 0,
      ),
    );
  }
}
