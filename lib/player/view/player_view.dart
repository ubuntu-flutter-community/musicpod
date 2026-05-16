import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/app_manager.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../player_model.dart';
import '../player_service.dart';
import 'bottom_player.dart';
import 'full_height_player.dart';

class PlayerView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PlayerView.bottom({super.key}) : _position = PlayerPosition.bottom;

  const PlayerView.sideBar({super.key}) : _position = PlayerPosition.sideBar;

  const PlayerView.fullWindow({super.key})
    : _position = PlayerPosition.fullWindow;

  final PlayerPosition _position;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      di<AppManager>().setShowWindowControls(
        widget._position != PlayerPosition.sideBar,
      );
    });
  }

  @override
  void didUpdateWidget(covariant PlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      di<AppManager>().setShowWindowControls(
        widget._position != PlayerPosition.sideBar,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    registerStreamHandler(
      select: (PlayerModel m) => m.errorStream,
      handler: (context, newValue, cancel) => context.toast(
        Text(switch (newValue) {
          final PlayTimeoutException _ => context.l10n.playingMediaTimedOut,
          final Exception e => e.toString(),
          _ => 'Unknown error',
        }),
      ),
    );

    final theme = context.theme;
    final playerBg = getPlayerBg(
      theme,
      watchPropertyValue((PlayerModel m) => m.color ?? theme.cardColor),
      blendAmount: widget._position == PlayerPosition.bottom ? 0.1 : 0.3,
      saturation: widget._position == PlayerPosition.bottom ? -0.3 : -0.4,
    );
    return RepaintBoundary(
      child: Material(
        child: Container(
          decoration: BoxDecoration(
            color: widget._position != PlayerPosition.bottom ? null : playerBg,
            gradient: widget._position.getGradient(playerBg),
          ),
          child: widget._position != PlayerPosition.bottom
              ? FullHeightPlayer(playerPosition: widget._position)
              : const BottomPlayer(),
        ),
      ),
    );
  }
}

enum PlayerPosition {
  bottom,
  sideBar,
  fullWindow;

  LinearGradient getGradient(Color color) {
    final colors = [color, color.withValues(alpha: 0.01)];
    return switch (this) {
      PlayerPosition.bottom => LinearGradient(
        colors: colors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      PlayerPosition.sideBar => LinearGradient(
        colors: colors,
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      PlayerPosition.fullWindow => LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    };
  }
}
