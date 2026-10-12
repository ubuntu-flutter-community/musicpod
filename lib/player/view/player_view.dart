import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import '../manager/player_color_manager.dart';
import 'bottom_player.dart';
import 'full_window_player.dart';

class PlayerView extends ConsumerWidget {
  const PlayerView.bottom({super.key}) : _position = PlayerPosition.bottom;

  const PlayerView.fullWindow({super.key})
    : _position = PlayerPosition.fullWindow;

  final PlayerPosition _position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final baseColor = theme.cardColor;
    final playerColor = ref.watch(playerColorManagerProvider) ?? baseColor;

    final usePlayerColor =
        ref.watch(settingsBoolManagerProvider(SPKeys.usePlayerColor)) ?? true;

    final playerBg = !usePlayerColor
        ? baseColor
        : getPlayerBg(
            theme,
            playerColor,
            blendAmount: _position == PlayerPosition.bottom
                ? (theme.isLight ? 0.2 : 0.3)
                : 0.3,
            saturation: _position == PlayerPosition.bottom ? -0.3 : -0.4,
          );
    return RepaintBoundary(
      child: Material(
        child: Container(
          decoration: BoxDecoration(gradient: _position.getGradient(playerBg)),
          child: _position != PlayerPosition.bottom
              ? FullWindowPlayer(playerPosition: _position)
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
