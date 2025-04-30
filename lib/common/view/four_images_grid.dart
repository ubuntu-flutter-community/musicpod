import 'package:flutter/material.dart';

import 'theme.dart';

class FourImagesGrid extends StatelessWidget {
  const FourImagesGrid({
    super.key,
    required this.images,
  });

  final List<Widget> images;

  @override
  Widget build(BuildContext context) => Column(
        children: space(
          heightGap: 0,
          expandAll: true,
          children: [
            Row(
              children: space(
                widthGap: 0,
                expandAll: true,
                children: [
                  images.elementAt(0),
                  images.elementAt(1),
                ],
              ),
            ),
            Row(
              children: space(
                widthGap: 0,
                expandAll: true,
                children: [
                  images.elementAt(2),
                  images.elementAt(3),
                ],
              ),
            ),
          ],
        ),
      );
}
