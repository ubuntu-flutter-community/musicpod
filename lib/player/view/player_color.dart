import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../settings/settings_model.dart';
import '../player_model.dart';
import 'full_height_player_image.dart';
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
    final blurredPlayerBackground = watchPropertyValue(
      (SettingsModel m) => m.blurredPlayerBackground,
    );

    if (blurredPlayerBackground) {
      return _BlurredPlayerColor(size: size);
    }

    final baseColor = watchPropertyValue(
      (PlayerModel m) => m.color?.withValues(
        alpha:
            theme.isLight ||
                theme.scaffoldBackgroundColor != kMobileScaffoldBackgroundColor
            ? 0.4
            : 1,
      ),
    );

    final color =
        baseColor?.scale(lightness: theme.isLight ? -0.1 : 0.2) ??
        theme.scaffoldBackgroundColor;

    return Opacity(
      opacity: alpha * 0.8,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(gradient: position.getGradient(color)),
      ),
    );
  }
}

class _BlurredPlayerColor extends StatelessWidget {
  const _BlurredPlayerColor({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Opacity(
      opacity: theme.isLight ? 0.8 : 0.9,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Blur(
          blur: 90,
          colorOpacity: theme.isLight ? 0.6 : 0.7,
          blurColor: theme.isLight
              ? Colors.white
              : theme.scaffoldBackgroundColor,
          child: FullHeightPlayerImage(
            emptyFallBack: true,
            borderRadius: BorderRadius.zero,
            fit: BoxFit.cover,
            height: size.height,
            width: size.width,
          ),
        ),
      ),
    );
  }
}
