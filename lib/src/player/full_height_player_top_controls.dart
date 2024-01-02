import '../../common.dart';
import '../../data.dart';
import '../../player.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class FullHeightPlayerTopControls extends StatelessWidget {
  const FullHeightPlayerTopControls({
    super.key,
    required this.audio,
    required this.liked,
    required this.isStarredStation,
    required this.removeStarredStation,
    required this.addStarredStation,
    required this.removeLikedAudio,
    required this.addLikedAudio,
    required this.iconColor,
    required this.activeControls,
    required this.playerViewMode,
    required this.setFullScreen,
  });

  final Audio? audio;
  final bool liked;
  final bool isStarredStation;
  final void Function(String station) removeStarredStation;
  final void Function(String name, Set<Audio> stations) addStarredStation;
  final void Function(Audio audio, bool notify) removeLikedAudio;
  final void Function(Audio audio, bool notify) addLikedAudio;
  final Color iconColor;
  final bool activeControls;
  final PlayerViewMode playerViewMode;
  final void Function(bool? p1) setFullScreen;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 7.0,
      children: [
        LikeIconButton(
          audio: audio,
          liked: liked,
          isStarredStation: isStarredStation,
          removeStarredStation: removeStarredStation,
          addStarredStation: addStarredStation,
          removeLikedAudio: removeLikedAudio,
          addLikedAudio: addLikedAudio,
          color: iconColor,
        ),
        QueueButton(
          color: iconColor,
        ),
        ShareButton(
          audio: audio,
          active: activeControls,
          color: iconColor,
        ),
        VolumeSliderPopup(
          direction: PopoverDirection.bottom,
          color: iconColor,
        ),
        IconButton(
          icon: Icon(
            playerViewMode == PlayerViewMode.fullWindow
                ? Iconz().fullScreenExit
                : Iconz().fullScreen,
            color: iconColor,
          ),
          onPressed: () => setFullScreen(
            playerViewMode == PlayerViewMode.fullWindow ? false : true,
          ),
        ),
      ],
    );
  }
}
