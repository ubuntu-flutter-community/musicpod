import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../player_model.dart';

class PlayerColor extends StatelessWidget with WatchItMixin {
  const PlayerColor({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color =
        watchPropertyValue((PlayerModel m) => m.color?.withValues(alpha: 0.5));

    return Opacity(
      opacity: theme.isLight ? 0.7 : 0.9,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (color ?? theme.cardColor).withValues(alpha: 0.05),
              color ?? theme.cardColor,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      ),
    );
  }
}
