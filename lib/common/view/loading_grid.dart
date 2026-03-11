import 'package:flutter/material.dart';

import '../data/audio.dart';
import 'audio_card.dart';
import 'audio_card_bottom.dart';
import 'theme.dart';
import 'ui_constants.dart';

class LoadingGrid extends StatelessWidget {
  const LoadingGrid({super.key, required this.limit});

  final int limit;

  @override
  Widget build(BuildContext context) => GridView(
    gridDelegate: audioCardGridDelegate,
    padding: kGridPadding,
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

class SliverLoadingGrid extends StatelessWidget {
  const SliverLoadingGrid({super.key, required this.limit});

  final int limit;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      itemCount: limit,
      gridDelegate: audioCardGridDelegate,
      itemBuilder: (context, index) => const AudioCard(
        color: Colors.transparent,
        showBorder: false,
        bottom: AudioCardBottom(),
      ),
    );
  }
}
