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
    this.backgroundColor,
  });

  final List<Widget> images;
  final String fallBackText;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final boxShadow = BoxShadow(
      offset: const Offset(0, 0),
      spreadRadius: 1,
      blurRadius: 1,
      color: theme.shadowColor.withValues(alpha: 0.4),
    );
    final color = backgroundColor ??
        getAlphabetColor(fallBackText).scale(saturation: -0.2);

    final linearGradient = LinearGradient(
      colors: [
        color,
        color.scale(saturation: -0.6),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    if (images.length == 1) {
      return images.first;
    }

    if (images.isNotEmpty) {
      if (images.length >= 4) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [boxShadow],
            gradient: linearGradient,
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
        gradient: linearGradient,
        boxShadow: [boxShadow],
      ),
    );
  }
}

class ArtistVignette extends StatelessWidget {
  const ArtistVignette({
    super.key,
    required this.text,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
  });

  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: backgroundColor != Colors.transparent
              ? [
                  BoxShadow(
                    offset: const Offset(0, 1),
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 3,
                    spreadRadius: 0.1,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: backgroundColor == Colors.transparent
                ? FontWeight.w400
                : FontWeight.w200,
            fontSize: 15,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
