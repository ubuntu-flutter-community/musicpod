import 'package:flutter/material.dart';

class PodcastIconButtonProgress extends StatelessWidget {
  const PodcastIconButtonProgress({super.key});

  @override
  Widget build(BuildContext context) => const Positioned.fill(
    child: IgnorePointer(
      child: Padding(
        padding: EdgeInsets.all(1.5),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );
}
