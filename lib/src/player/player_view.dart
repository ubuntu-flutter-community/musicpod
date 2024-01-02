import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../player.dart';
import '../../theme_data_x.dart';
import '../library/library_model.dart';
import '../theme.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    super.key,
    required this.playerViewMode,
    required this.onTextTap,
    required this.isOnline,
  });

  final PlayerViewMode playerViewMode;
  final void Function({required String text, required AudioType audioType})
      onTextTap;
  final bool isOnline;

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

    final playerModel = context.read<PlayerModel>();
    final nextAudio = context.select((PlayerModel m) => m.nextAudio);
    final c = context.select((PlayerModel m) => m.color);
    final color = getPlayerBg(
      c,
      theme.isLight ? kCardColorLight : kCardColorDark,
    );
    final setFullScreen = playerModel.setFullScreen;
    final playPrevious = playerModel.playPrevious;
    final playNext = playerModel.playNext;
    final audio = context.select((PlayerModel m) => m.audio);

    final library = context.read<LibraryModel>();
    final liked = library.liked(audio);

    final removeLikedAudio = library.removeLikedAudio;
    final addLikedAudio = library.addLikedAudio;
    final addStarredStation = library.addStarredStation;
    final removeStarredStation = library.unStarStation;
    final isStarredStation = library.isStarredStation(audio?.title);

    final isVideo = context.select((PlayerModel m) => m.isVideo);

    Widget player;
    if (widget.playerViewMode != PlayerViewMode.bottom) {
      player = FullHeightPlayer(
        isVideo: isVideo == true,
        videoController: playerModel.controller,
        playerViewMode: widget.playerViewMode,
        onTextTap: widget.onTextTap,
        setFullScreen: setFullScreen,
        nextAudio: nextAudio,
        audio: audio,
        playPrevious: playPrevious,
        playNext: playNext,
        liked: liked,
        isStarredStation: isStarredStation,
        addStarredStation: addStarredStation,
        removeStarredStation: removeStarredStation,
        addLikedAudio: addLikedAudio,
        removeLikedAudio: removeLikedAudio,
        isOnline: widget.isOnline,
      );
    } else {
      player = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          BottomPlayer(
            isVideo: isVideo,
            videoController: playerModel.controller,
            onTextTap: widget.onTextTap,
            setFullScreen: setFullScreen,
            audio: audio,
            playPrevious: playPrevious,
            playNext: playNext,
            liked: liked,
            isStarredStation: isStarredStation,
            addStarredStation: addStarredStation,
            removeStarredStation: removeStarredStation,
            addLikedAudio: addLikedAudio,
            removeLikedAudio: removeLikedAudio,
            isOnline: widget.isOnline,
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
