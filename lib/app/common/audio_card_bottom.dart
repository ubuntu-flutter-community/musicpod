import 'package:flutter/material.dart';
import 'package:musicpod/constants.dart';

class AudioCardBottom extends StatelessWidget {
  const AudioCardBottom({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Tooltip(
        message: text,
        child: Container(
          width: double.infinity,
          height: kCardBottomHeight,
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
