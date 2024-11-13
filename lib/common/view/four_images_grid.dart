import 'package:flutter/material.dart';

class FourImagesGrid extends StatelessWidget {
  const FourImagesGrid({
    super.key,
    required this.images,
  });

  final List<Widget> images;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: images.elementAt(0),
              ),
              Expanded(
                child: images.elementAt(1),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: images.elementAt(2),
              ),
              Expanded(
                child: images.elementAt(3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
