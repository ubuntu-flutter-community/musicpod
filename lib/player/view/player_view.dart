import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/app_model.dart';
import '../../extensions/build_context_x.dart';
import '../../external_path/external_path_service.dart';
import 'bottom_player.dart';
import 'full_height_player.dart';

class PlayerView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PlayerView({super.key, required this.position});

  final PlayerPosition position;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  @override
  void initState() {
    super.initState();
    di<ExternalPathService>().init();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      di<AppModel>().setShowWindowControls(
        widget.position != PlayerPosition.sideBar,
      );
    });
  }

  @override
  void didUpdateWidget(covariant PlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      di<AppModel>().setShowWindowControls(
        widget.position != PlayerPosition.sideBar,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    Widget player;
    if (widget.position != PlayerPosition.bottom) {
      player = Row(
        children: [
          if (widget.position == PlayerPosition.sideBar)
            const Material(child: VerticalDivider()),
          Expanded(
            child: FullHeightPlayer(playerPosition: widget.position),
          ),
        ],
      );
    } else {
      player = const BottomPlayer();
    }

    // VERY important to reduce CPU usage
    return RepaintBoundary(
      child: Material(
        color: theme.cardColor,
        child: player,
      ),
    );
  }
}

enum PlayerPosition {
  bottom,
  sideBar,
  fullWindow,
}
