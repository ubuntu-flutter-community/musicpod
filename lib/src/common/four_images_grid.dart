import 'dart:typed_data';

import 'package:flutter/material.dart';

class FourImagesGrid extends StatelessWidget {
  const FourImagesGrid({
    super.key,
    required this.images,
    this.fit = BoxFit.cover,
  });

  final Set<Uint8List> images;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _Image(
                  bytes: images.elementAt(0),
                  fit: fit,
                ),
              ),
              Expanded(
                child: _Image(
                  bytes: images.elementAt(1),
                  fit: fit,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _Image(
                  bytes: images.elementAt(2),
                  fit: fit,
                ),
              ),
              Expanded(
                child: _Image(
                  bytes: images.elementAt(3),
                  fit: fit,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Image extends StatelessWidget {
  final Uint8List bytes;

  const _Image({
    required this.bytes,
    required this.fit,
  });

  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    const quality = FilterQuality.medium;
    const height = double.infinity;
    const width = double.infinity;
    return Image.memory(
      bytes,
      height: height,
      width: width,
      fit: fit,
      filterQuality: quality,
    );
  }
}
