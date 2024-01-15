import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../constants.dart';
import '../../player.dart';
import '../../theme_data_x.dart';
import '../app/connectivity_notifier.dart';
import '../theme.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    super.key,
    required this.playerViewMode,
  });

  final PlayerViewMode playerViewMode;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      context.read<AppModel>().setShowWindowControls(
            widget.playerViewMode != PlayerViewMode.sideBar,
          );
    });
  }

  @override
  void didUpdateWidget(covariant PlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      context.read<AppModel>().setShowWindowControls(
            widget.playerViewMode != PlayerViewMode.sideBar,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    // Connectivity
    final isOnline = context.watch<ConnectivityNotifier>().isOnline;

    final playerModel = context.read<PlayerModel>();
    final appModel = context.read<AppModel>();
    final nextAudio = context.select((PlayerModel m) => m.nextAudio);
    final c = context.select((PlayerModel m) => m.color);
    final color = getPlayerBg(
      c,
      theme.isLight ? kCardColorLight : kCardColorDark,
    );
    final setFullScreen = appModel.setFullScreen;
    final playPrevious = playerModel.playPrevious;
    final playNext = playerModel.playNext;
    final audio = context.select((PlayerModel m) => m.audio);

    final isVideo = context.select((PlayerModel m) => m.isVideo);

    Widget player;
    if (widget.playerViewMode != PlayerViewMode.bottom) {
      player = FullHeightPlayer(
        isVideo: isVideo == true,
        videoController: playerModel.controller,
        playerViewMode: widget.playerViewMode,
        setFullScreen: setFullScreen,
        nextAudio: nextAudio,
        audio: audio,
        playPrevious: playPrevious,
        playNext: playNext,
        isOnline: isOnline,
      );
    } else {
      player = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          BottomPlayer(
            isVideo: isVideo,
            videoController: playerModel.controller,
            setFullScreen: setFullScreen,
            audio: audio,
            playPrevious: playPrevious,
            playNext: playNext,
            isOnline: isOnline,
          ),
        ],
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
