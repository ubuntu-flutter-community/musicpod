import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../settings/settings_model.dart';
import '../player_model.dart';
import 'bottom_player.dart';
import 'full_height_player.dart';

class PlayerView extends StatelessWidget with WatchItMixin {
  const PlayerView.bottom({super.key}) : _position = PlayerPosition.bottom;

  const PlayerView.fullWindow({super.key})
    : _position = PlayerPosition.fullWindow;

  final PlayerPosition _position;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final baseColor = theme.cardColor;
    final usePlayerColor = watchPropertyValue(
      (SettingsModel m) => m.usePlayerColor,
    );
    final playerBg = !usePlayerColor
        ? baseColor
        : getPlayerBg(
            theme,
            watchPropertyValue((PlayerModel m) => m.color ?? baseColor),
            blendAmount: _position == PlayerPosition.bottom
                ? (theme.isLight ? 0.2 : 0.3)
                : 0.3,
            saturation: _position == PlayerPosition.bottom ? -0.3 : -0.4,
          );
    return RepaintBoundary(
      child: Material(
        child: Container(
          decoration: BoxDecoration(
            color: _position != PlayerPosition.bottom ? null : playerBg,
            gradient: _position.getGradient(playerBg),
          ),
          child: _position != PlayerPosition.bottom
              ? FullHeightPlayer(playerPosition: _position)
              : const BottomPlayer(),
        ),
      ),
    );
  }
}

enum PlayerPosition {
  bottom,
  fullWindow;

  LinearGradient getGradient(Color color) {
    final colors = [color, color.withValues(alpha: 0.01)];
    return switch (this) {
      PlayerPosition.bottom => LinearGradient(
        colors: colors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      PlayerPosition.fullWindow => LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    };
  }
}
