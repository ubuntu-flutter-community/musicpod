import 'package:flutter/material.dart';

class NoSearchResultPage extends StatelessWidget {
  const NoSearchResultPage({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🐣🎙🎧❓',
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              message,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w100,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
