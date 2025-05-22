import 'package:flutter/material.dart';

import 'theme.dart';

class CoverBackground extends StatelessWidget {
  const CoverBackground({super.key, this.dimension});

  final double? dimension;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/media-optical.png',
      height: dimension ?? audioCardDimension,
      width: dimension ?? audioCardDimension,
    );
  }
}
