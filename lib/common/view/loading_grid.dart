import 'package:flutter/material.dart';

import '../data/audio.dart';
import 'audio_card.dart';
import 'audio_card_bottom.dart';
import 'common_widgets.dart';

class LoadingGrid extends StatelessWidget {
  const LoadingGrid({
    super.key,
    required this.limit,
  });

  final int limit;

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate: audioCardGridDelegate,
      padding: gridPadding,
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
  }
}
