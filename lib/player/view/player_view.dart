import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/app_model.dart';
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
      di<AppModel>().setShowWindowControls(
        widget._position != PlayerPosition.sideBar,
      );
    });
  }

  @override
  void didUpdateWidget(covariant PlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      di<AppModel>().setShowWindowControls(
        widget._position != PlayerPosition.sideBar,
      );
    });
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: widget._position != PlayerPosition.bottom
        ? FullHeightPlayer(playerPosition: widget._position)
        : const BottomPlayer(),
  );
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
