import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../data.dart';
import '../../player.dart';
import '../library/library_model.dart';

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
    final playerModel = context.read<PlayerModel>();
    final audio = context.select((PlayerModel m) => m.audio);
    final mpvMetaData = context.select((PlayerModel m) => m.mpvMetaData);
    final nextAudio = context.select((PlayerModel m) => m.nextAudio);
    final queue = context.select((PlayerModel m) => m.queue);
    final repeatSingle = context.select((PlayerModel m) => m.repeatSingle);
    final setRepeatSingle = playerModel.setRepeatSingle;
    final shuffle = context.select((PlayerModel m) => m.shuffle);
    final setShuffle = playerModel.setShuffle;

    final color = context.select((PlayerModel m) => m.color);

    final isUpNextExpanded =
        context.select((PlayerModel m) => m.isUpNextExpanded);
    final setUpNextExpanded = playerModel.setUpNextExpanded;
    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final setFullScreen = playerModel.setFullScreen;
    final playPrevious = playerModel.playPrevious;
    final playNext = playerModel.playNext;
    final pause = playerModel.pause;
    final playOrPause = playerModel.playOrPause;

    final library = context.read<LibraryModel>();
    final liked = audio == null
        ? false
        : context.select((LibraryModel m) => m.likedAudios.contains(audio));
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final removeLikedAudio = library.removeLikedAudio;
    final addLikedAudio = library.addLikedAudio;
    final addStarredStation = library.addStarredStation;
    final removeStarredStation = library.unStarStation;
    final isStarredStation = audio == null
        ? false
        : context.select(
            (LibraryModel m) => m.starredStations.containsKey(
              audio.title,
            ),
          );

    final isVideo = context.select((PlayerModel m) => m.isVideo);

    Widget player;
    if (widget.playerViewMode != PlayerViewMode.bottom) {
      player = FullHeightPlayer(
        isVideo: isVideo == true,
        videoController: playerModel.controller,
        playerViewMode: widget.playerViewMode,
        onTextTap: widget.onTextTap,
        setFullScreen: setFullScreen,
        isUpNextExpanded: isUpNextExpanded,
        nextAudio: nextAudio,
        queue: queue,
        setUpNextExpanded: setUpNextExpanded,
        audio: audio,
        mpvMetaData: mpvMetaData,
        color: color,
        setRepeatSingle: setRepeatSingle,
        repeatSingle: repeatSingle,
        shuffle: shuffle,
        setShuffle: setShuffle,
        isPlaying: isPlaying,
        playPrevious: playPrevious,
        playNext: playNext,
        pause: pause,
        playOrPause: playOrPause,
        liked: liked,
        isStarredStation: isStarredStation,
        addStarredStation: addStarredStation,
        removeStarredStation: removeStarredStation,
        addLikedAudio: addLikedAudio,
        removeLikedAudio: removeLikedAudio,
        isOnline: widget.isOnline,
        size: size,
      );
    } else {
      player = BottomPlayer(
        isVideo: isVideo,
        videoController: playerModel.controller,
        onTextTap: widget.onTextTap,
        setFullScreen: setFullScreen,
        audio: audio,
        mpvMetaData: mpvMetaData,
        width: width,
        color: color,
        setRepeatSingle: setRepeatSingle,
        repeatSingle: repeatSingle,
        shuffle: shuffle,
        setShuffle: setShuffle,
        isPlaying: isPlaying,
        playPrevious: playPrevious,
        playNext: playNext,
        pause: pause,
        playOrPause: playOrPause,
        liked: liked,
        isStarredStation: isStarredStation,
        addStarredStation: addStarredStation,
        removeStarredStation: removeStarredStation,
        addLikedAudio: addLikedAudio,
        removeLikedAudio: removeLikedAudio,
        queue: queue,
        isOnline: widget.isOnline,
      );
    }

    // VERY important to reduce CPU usage
    return RepaintBoundary(child: player);
  }
}

enum PlayerViewMode {
  bottom,
  sideBar,
  fullWindow,
}
