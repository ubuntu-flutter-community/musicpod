import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../player_model.dart';

class PlayerColor extends StatelessWidget with WatchItMixin {
  const PlayerColor({super.key, required this.size, required this.alpha});

  final Size size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final baseColor = watchPropertyValue((PlayerModel m) => m.color);

    final color = baseColor ?? theme.cardColor;
    return Opacity(
      opacity: alpha * (theme.isLight ? 0.8 : 0.9),
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.02),
              color,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      ),
    );
  }
}
