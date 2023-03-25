import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  const ImageGrid({
    super.key,
    required this.images,
    this.gridSize = 200.0,
  });

  final Set<Uint8List>? images;
  final double gridSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: gridSize,
      width: gridSize,
      child: Column(
        children: [
          SizedBox(
            height: gridSize / 2,
            child: Row(
              children: [
                Image.memory(
                  images!.elementAt(0),
                  width: gridSize / 2,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                ),
                Image.memory(
                  images!.elementAt(1),
                  width: gridSize / 2,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                )
              ],
            ),
          ),
          SizedBox(
            height: gridSize / 2,
            child: Row(
              children: [
                Image.memory(
                  images!.elementAt(2),
                  width: gridSize / 2,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                ),
                Image.memory(
                  images!.elementAt(3),
                  width: gridSize / 2,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
