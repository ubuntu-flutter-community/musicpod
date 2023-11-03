import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

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

  Color? getColorFromName(String name) {
    final firstChar = name.isEmpty ? 'a' : name.substring(0, 1);

    return <String, Color>{
      'a': Colors.red,
      'b': Colors.green,
      'c': Colors.blue,
      'd': Colors.yellow,
      'e': Colors.orange,
      'f': Colors.purple,
      'g': Colors.pink,
      'h': Colors.brown,
      'i': Colors.black,
      'j': Colors.white,
      'k': Colors.grey,
      'l': Colors.cyan,
      'm': YaruColors.magenta,
      'n': YaruColors.olive,
      'o': Colors.teal,
      'p': Colors.lime,
      'q': Colors.lightBlue,
      'r': Colors.blueGrey,
      's': Colors.orangeAccent,
      't': Colors.amberAccent,
      'u': Colors.greenAccent,
      'v': Colors.lightGreen,
      'w': Colors.indigo,
      'x': Colors.lightGreenAccent,
      'y': Colors.purpleAccent,
      'z': Colors.deepPurple,
    }[firstChar];
  }
}
