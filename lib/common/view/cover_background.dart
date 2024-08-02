import '../../constants.dart';
import 'package:flutter/material.dart';

class CoverBackground extends StatelessWidget {
  const CoverBackground({
    super.key,
    this.dimension = kAudioCardDimension,
  });

  final double dimension;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/media-optical.png',
      height: dimension,
      width: dimension,
    );
  }
}
