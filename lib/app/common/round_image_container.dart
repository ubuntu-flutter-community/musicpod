import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class RoundImageContainer extends StatelessWidget {
  const RoundImageContainer({
    super.key,
    required this.text,
    this.image,
  });

  final Uint8List? image;
  final Text text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? bg;
    if (image == null) {
      Random random = Random();
      bg = Color.fromRGBO(
        random.nextInt(255),
        random.nextInt(255),
        random.nextInt(255),
        1,
      ).withOpacity(0.7);
    }
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        image: image != null
            ? DecorationImage(
                image: MemoryImage(image!),
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
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
          ),
          child: text,
        ),
      ),
    );
  }
}
