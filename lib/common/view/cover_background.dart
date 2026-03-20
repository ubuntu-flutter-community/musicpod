import 'package:flutter/material.dart';

class CoverBackground extends StatelessWidget {
  const CoverBackground({super.key, required this.dimension});

  final double dimension;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/media-optical.png',
    height: dimension,
    width: dimension,
    cacheHeight: dimension.toInt(),
    cacheWidth: dimension.toInt(),
  );
}
