import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/connectivity_model.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../player/player_model.dart';
import 'full_height_player_audio_body.dart';
import 'full_height_player_header_bar.dart';
import 'full_height_player_top_controls.dart';
import 'full_height_video_player.dart';
import 'player_color.dart';
import 'player_view.dart';

class FullHeightPlayer extends StatelessWidget with WatchItMixin {
  const FullHeightPlayer({super.key, required this.playerPosition});

  final PlayerPosition playerPosition;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final size = context.mediaQuerySize;
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo == true);
    final active = audio?.path != null || isOnline;
    final iconColor = isVideo ? Colors.white : theme.colorScheme.onSurface;

    final Widget body;
    if (isVideo) {
      body = isLinux
          ? Stack(
              alignment: Alignment.topRight,
              children: [
                SimpleFullHeightVideoPlayer(
                  controls: (state) => MaterialVideoControls(state),
                ),
                FullHeightPlayerTopControls(
                  iconColor: iconColor,
                  playerPosition: playerPosition,
                ),
              ],
            )
          : FullHeightVideoPlayer(
              playerPosition: playerPosition,
              audio: audio,
              controlsActive: active,
            );
    } else {
      body = FullHeightPlayerAudioBody(
        active: active,
        iconColor: iconColor,
        playerPosition: playerPosition,
        audio: audio,
      );
    }

    return Stack(
      children: [
        if (!isVideo)
          PlayerColor(alpha: 0.4, size: size, position: playerPosition),
        Column(
          children: [
            if (!isMobile) FullHeightPlayerHeaderBar(isVideo: isVideo),
            Expanded(child: body),
          ],
        ),
      ],
    );
  }
}
