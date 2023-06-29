import 'package:flutter/material.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/player/bottom_player.dart';
import 'package:musicpod/app/player/full_height_player.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:provider/provider.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({
    super.key,
    this.isSideBarPlayer = false,
  });

  final bool isSideBarPlayer;

  @override
  Widget build(BuildContext context) {
    final playerModel = context.read<PlayerModel>();
    final audio = context.select((PlayerModel m) => m.audio);
    final nextAudio = context.select((PlayerModel m) => m.nextAudio);
    final queue = context.select((PlayerModel m) => m.queue);
    final repeatSingle = context.select((PlayerModel m) => m.repeatSingle);
    final setRepeatSingle = playerModel.setRepeatSingle;
    final shuffle = context.select((PlayerModel m) => m.shuffle);
    final setShuffle = playerModel.setShuffle;
    final position = context.select((PlayerModel m) => m.position);
    final setPosition = playerModel.setPosition;
    final duration = context.select((PlayerModel m) => m.duration);
    final color = context.select((PlayerModel m) => m.color);
    final seek = playerModel.seek;

    final isUpNextExpanded =
        context.select((PlayerModel m) => m.isUpNextExpanded);
    final setUpNextExpanded = playerModel.setUpNextExpanded;
    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final fullScreen = context.select((PlayerModel m) => m.fullScreen);
    final setFullScreen = playerModel.setFullScreen;
    final playPrevious = playerModel.playPrevious;
    final playNext = playerModel.playNext;
    final pause = playerModel.pause;
    final playOrPause = playerModel.playOrPause;

    final library = context.read<LibraryModel>();
    final liked = audio == null
        ? false
        : context.select((LibraryModel m) => m.likedAudios.contains(audio));
    final width = MediaQuery.of(context).size.width;
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

    final setSpotlightAudio = library.setSpotlightAudio;

    final showFullHeightPlayer = isSideBarPlayer || fullScreen == true;

    if (showFullHeightPlayer) {
      return FullHeightPlayer(
        expandHeight: isSideBarPlayer,
        fullScreen: showFullHeightPlayer,
        setFullScreen: setFullScreen,
        isUpNextExpanded: isUpNextExpanded,
        nextAudio: nextAudio,
        queue: queue,
        setUpNextExpanded: setUpNextExpanded,
        audio: audio,
        color: color,
        duration: duration,
        position: position,
        setPosition: setPosition,
        seek: seek,
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
      );
    }

    return BottomPlayer(
      setFullScreen: setFullScreen,
      audio: audio,
      setSpotlightAudio: setSpotlightAudio,
      width: width,
      color: color,
      duration: duration,
      position: position,
      setPosition: setPosition,
      seek: seek,
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
    );
  }
}
