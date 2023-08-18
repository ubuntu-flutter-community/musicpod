import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:musicpod/utils.dart';

class RoundImageContainer extends StatelessWidget {
  const RoundImageContainer({
    super.key,
    required this.text,
    this.image,
  });

  final Uint8List? image;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? bg;
    if (image == null) {
      bg = (getColorFromName(text) ?? theme.colorScheme.background)
          .withOpacity(0.7);
    }
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 1),
            color: Colors.black.withOpacity(0.5),
            blurRadius: 3,
            spreadRadius: 3,
          ),
        ],
        image: image != null
            ? DecorationImage(
                image: MemoryImage(image!),
                fit: BoxFit.cover,
              )
            : null,
        gradient: bg == null
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bg,
                  theme.colorScheme.inverseSurface,
                ],
              ),
      ),
      child: Center(
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
      ),
    );
  }
}
