import 'dart:typed_data';

import 'package:flutter/material.dart';

class FourImagesGrid extends StatelessWidget {
  const FourImagesGrid({
    super.key,
    required this.images,
  });

  final Set<Uint8List> images;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _Image(bytes: images.elementAt(0)),
              ),
              Expanded(
                child: _Image(bytes: images.elementAt(1)),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _Image(bytes: images.elementAt(2)),
              ),
              Expanded(
                child: _Image(bytes: images.elementAt(3)),
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

  const _Image({required this.bytes});

  @override
  Widget build(BuildContext context) {
    const fit = BoxFit.cover;
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
