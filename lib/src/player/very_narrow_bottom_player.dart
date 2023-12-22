import 'dart:io';

import 'package:flutter/material.dart';

import '../../player.dart';
import 'bottom_player_image.dart';
import 'bottom_player_title_artist.dart';
import 'play_button.dart';

class VeryNarrowBottomPlayer extends StatelessWidget {
  const VeryNarrowBottomPlayer({
    super.key,
    required this.setFullScreen,
    required this.bottomPlayerImage,
    required this.titleAndArtist,
    required this.active,
    required this.isOnline,
    required this.track,
  });

  final void Function(bool? p1) setFullScreen;
  final BottomPlayerImage bottomPlayerImage;
  final BottomPlayerTitleArtist titleAndArtist;
  final bool active;
  final bool isOnline;
  final PlayerTrack track;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (Platform.isAndroid) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! < 150) {
            setFullScreen(true);
          }
        }
      },
      child: InkWell(
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
                      child: PlayButton(active: active),
                    ),
                  ],
                ),
              ),
              track,
            ],
          ),
        ),
      ),
    );
  }
}
