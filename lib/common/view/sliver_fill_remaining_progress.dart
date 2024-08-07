import 'package:flutter/material.dart';
import 'progress.dart';

class SliverFillRemainingProgress extends StatelessWidget {
  const SliverFillRemainingProgress({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Progress(),
      ),
    );
  }
}
