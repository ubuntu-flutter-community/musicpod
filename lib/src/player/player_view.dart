import 'package:flutter/material.dart';
import '../../get.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../player.dart';
import '../theme.dart';

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

    final isOnline = watchPropertyValue((AppModel m) => m.isOnline);
    final playerModel = getIt<PlayerModel>();
    final appModel = getIt<AppModel>();
    final nextAudio = watchPropertyValue((PlayerModel m) => m.nextAudio);
    final c = watchPropertyValue((PlayerModel m) => m.color);
    final color = getPlayerBg(
      c,
      theme.cardColor,
    );
    final playPrevious = playerModel.playPrevious;
    final playNext = playerModel.playNext;
    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo);

    Widget player;
    if (widget.mode != PlayerViewMode.bottom) {
      player = Row(
        children: [
          if (widget.mode == PlayerViewMode.sideBar)
            const Material(child: VerticalDivider()),
          Expanded(
            child: FullHeightPlayer(
              isVideo: isVideo == true,
              videoController: playerModel.controller,
              playerViewMode: widget.mode,
              appModel: appModel,
              nextAudio: nextAudio,
              audio: audio,
              playPrevious: playPrevious,
              playNext: playNext,
              isOnline: isOnline,
            ),
          ),
        ],
      );
    } else {
      player = BottomPlayer(
        isVideo: isVideo,
        videoController: playerModel.controller,
        appModel: appModel,
        audio: audio,
        playPrevious: playPrevious,
        playNext: playNext,
        isOnline: isOnline,
      );
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
