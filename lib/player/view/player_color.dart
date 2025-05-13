import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../player_model.dart';
import 'player_view.dart';

class PlayerColor extends StatelessWidget with WatchItMixin {
  const PlayerColor({
    super.key,
    required this.size,
    required this.alpha,
    required this.position,
  });

  final Size size;
  final double alpha;
  final PlayerPosition position;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final baseColor =
        watchPropertyValue((PlayerModel m) => m.color?.withValues(alpha: 0.4));

    final color = baseColor?.scale(lightness: theme.isLight ? -0.1 : 0.2) ??
        theme.scaffoldBackgroundColor;

    return Opacity(
      opacity: alpha * 0.8,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: position.getGradient(color),
        ),
      ),
    );
  }
}
