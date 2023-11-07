import 'package:flutter/material.dart';
import '../../constants.dart';

class AudioCardBottom extends StatelessWidget {
  const AudioCardBottom({
    super.key,
    required this.text,
    this.maxLines = 1,
  });

  final String text;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Tooltip(
        message: text,
        child: Container(
          width: kSmallCardHeight,
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10,
          ),
          child: Text(
            text,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.9)),
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
            maxLines: maxLines,
          ),
        ),
      ),
    );
  }
}
