import 'package:flutter/material.dart';

class FourImagesGrid extends StatelessWidget {
  const FourImagesGrid({super.key, required this.images, this.dimension});

  final List<Widget> images;
  final double? dimension;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: Row(
          children: [
            images.elementAt(0),
            images.elementAt(1),
          ].map((e) => Expanded(child: e)).toList(),
        ),
      ),
      Expanded(
        child: Row(
          children: [
            images.elementAt(2),
            images.elementAt(3),
          ].map((e) => Expanded(child: e)).toList(),
        ),
      ),
    ],
  );
}
