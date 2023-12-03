import '../../common.dart';
import '../../data.dart';
import '../../player.dart';
import '../../theme.dart';
import 'bottom_player_image.dart';
import 'bottom_player_title_artist.dart';
import 'package:flutter/material.dart';

class VeryNarrowBottomPlayer extends StatelessWidget {
  const VeryNarrowBottomPlayer({
    super.key,
    required this.setFullScreen,
    required this.bottomPlayerImage,
    required this.titleAndArtist,
    required this.audio,
    required this.isOnline,
    required this.isPlaying,
    required this.pause,
    required this.playOrPause,
    required this.track,
  });

  final void Function(bool? p1) setFullScreen;
  final BottomPlayerImage bottomPlayerImage;
  final BottomPlayerTitleArtist titleAndArtist;
  final Audio? audio;
  final bool isOnline;
  final bool isPlaying;
  final Future<void> Function() pause;
  final Future<void> Function() playOrPause;
  final PlayerTrack track;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setFullScreen(true),
      child: SizedBox(
        height: kBottomPlayerHeight,
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: bottomPlayerImage,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: titleAndArtist,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: IconButton(
                      onPressed:
                          !(audio?.path != null || isOnline) || audio == null
                              ? null
                              : () {
                                  if (isPlaying) {
                                    pause();
                                  } else {
                                    playOrPause();
                                  }
                                },
                      icon: Padding(
                        padding: appleStyled
                            ? const EdgeInsets.only(left: 3)
                            : EdgeInsets.zero,
                        child: Icon(
                          isPlaying ? Iconz().pause : Iconz().play,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            track,
          ],
        ),
      ),
    );
  }
}
