import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../player.dart';
import '../theme.dart';

class PlayerView extends ConsumerStatefulWidget {
  const PlayerView({super.key, required this.mode});

  final PlayerViewMode mode;

  @override
  ConsumerState<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends ConsumerState<PlayerView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      ref.read(appModelProvider).setShowWindowControls(
            widget.mode != PlayerViewMode.sideBar,
          );
    });
  }

  @override
  void didUpdateWidget(covariant PlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      ref.read(appModelProvider).setShowWindowControls(
            widget.mode != PlayerViewMode.sideBar,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    final isOnline = ref.watch(appModelProvider.select((c) => c.isOnline));
    final playerModel = ref.read(playerModelProvider);
    final appModel = ref.read(appModelProvider);
    final nextAudio = ref.watch(playerModelProvider.select((m) => m.nextAudio));
    final c = ref.watch(playerModelProvider.select((m) => m.color));
    final color = getPlayerBg(
      c,
      theme.cardColor,
    );
    final playPrevious = playerModel.playPrevious;
    final playNext = playerModel.playNext;
    final audio = ref.watch(playerModelProvider.select((m) => m.audio));

    final isVideo = ref.watch(playerModelProvider.select((m) => m.isVideo));

    Widget player;
    if (widget.mode != PlayerViewMode.bottom) {
      player = Row(
        children: [
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
