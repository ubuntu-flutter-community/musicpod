import '../../common.dart';
import '../../data.dart';
import 'package:flutter/material.dart';

class LoadingGrid extends StatelessWidget {
  const LoadingGrid({
    super.key,
    required this.limit,
  });

  final int limit;

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate: imageGridDelegate,
      padding: gridPadding,
      children: List.generate(limit, (index) => const Audio())
          .map(
            (e) => const AudioCard(
              color: Colors.transparent,
              elevation: 0,
              bottom: AudioCardBottom(),
            ),
          )
          .toList(),
    );
  }
}
