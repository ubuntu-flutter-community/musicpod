import 'package:flutter/material.dart';

import '../data/audio.dart';
import 'adaptive_container.dart';
import 'audio_card.dart';
import 'audio_card_bottom.dart';
import 'theme.dart';

class LoadingGrid extends StatelessWidget {
  const LoadingGrid({
    super.key,
    required this.limit,
  });

  final int limit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView(
          gridDelegate: audioCardGridDelegate,
          padding: getAdaptiveHorizontalPadding(constraints: constraints),
          children: List.generate(limit, (index) => const Audio())
              .map(
                (e) => const AudioCard(
                  color: Colors.transparent,
                  showBorder: false,
                  bottom: AudioCardBottom(),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
