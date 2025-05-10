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
    this.dimension,
  });

  final List<Widget> images;
  final String fallBackText;
  final Color? backgroundColor;
  final double? dimension;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final boxShadow = BoxShadow(
      offset: const Offset(0, 0),
      spreadRadius: 1,
      blurRadius: 1,
      color: theme.shadowColor.withValues(alpha: 0.9),
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

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        gradient: linearGradient,
        boxShadow: [boxShadow],
        shape: BoxShape.circle,
      ),
      child: switch (images.length) {
        0 => null,
        1 => images.first,
        2 || 3 => Stack(
            children: [
              images.first,
              YaruClip.diagonal(
                position: YaruDiagonalClip.bottomLeft,
                child: images.elementAt(1),
              ),
            ],
          ),
        _ => FourImagesGrid(
            images: images.take(4).toList(),
          ),
      },
    );
  }
}

class RoundImageContainerVignette extends StatelessWidget {
  const RoundImageContainerVignette({
    super.key,
    required this.text,
    this.backgroundColor = const Color.fromARGB(255, 28, 28, 28),
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
