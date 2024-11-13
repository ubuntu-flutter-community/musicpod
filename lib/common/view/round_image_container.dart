import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import 'four_images_grid.dart';
import 'theme.dart';

class RoundImageContainer extends StatelessWidget {
  const RoundImageContainer({
    super.key,
    required this.images,
    required this.fallBackText,
  });

  final List<Widget> images;
  final String fallBackText;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final boxShadow = BoxShadow(
      offset: const Offset(0, 0),
      spreadRadius: 1,
      blurRadius: 1,
      color: theme.shadowColor.withOpacity(0.4),
    );

    if (images.length == 1) {
      return images.first;
    }

    if (images.isNotEmpty) {
      if (images.length >= 4) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              boxShadow,
            ],
          ),
          child: FourImagesGrid(
            images: images,
          ),
        );
      } else if (images.length >= 2) {
        return Stack(
          children: [
            images.first,
            YaruClip.diagonal(
              position: YaruDiagonalClip.bottomLeft,
              child: images.elementAt(1),
            ),
          ],
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: getAlphabetColor(fallBackText).scale(saturation: -0.6),
        boxShadow: [
          boxShadow,
        ],
      ),
    );
  }
}

class ArtistVignette extends StatelessWidget {
  const ArtistVignette({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.inverseSurface,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 1),
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              spreadRadius: 0.1,
            ),
          ],
        ),
        child: Text(
          text,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w100,
            fontSize: 15,
            color: theme.colorScheme.onInverseSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
