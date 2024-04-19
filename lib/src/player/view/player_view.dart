import 'package:flutter/material.dart';
import '../../../get.dart';

import '../../../app.dart';
import '../../../build_context_x.dart';
import '../../theme.dart';
import '../player_model.dart';
import 'bottom_player.dart';
import 'full_height_player.dart';

class PlayerView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PlayerView({super.key, required this.mode});

  final PlayerViewMode mode;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      getIt<AppModel>().setShowWindowControls(
        widget.mode != PlayerViewMode.sideBar,
      );
    });
  }

  @override
  void didUpdateWidget(covariant PlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      getIt<AppModel>().setShowWindowControls(
        widget.mode != PlayerViewMode.sideBar,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final c = watchPropertyValue((PlayerModel m) => m.color);
    final color = getPlayerBg(c, theme.cardColor);

    Widget player;
    if (widget.mode != PlayerViewMode.bottom) {
      player = Row(
        children: [
          if (widget.mode == PlayerViewMode.sideBar)
            const Material(child: VerticalDivider()),
          Expanded(
            child: FullHeightPlayer(playerViewMode: widget.mode),
          ),
        ],
      );
    } else {
      player = const BottomPlayer();
    }

    // VERY important to reduce CPU usage
    return RepaintBoundary(
      child: Material(
        color: color,
        child: player,
      ),
    );
  }
}

enum PlayerViewMode {
  bottom,
  sideBar,
  fullWindow,
}
