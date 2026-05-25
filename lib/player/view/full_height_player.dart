import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../player/player_model.dart';
import 'full_height_player_audio_body.dart';
import 'full_height_player_header_bar.dart';
import 'full_height_video_player.dart';
import 'player_view.dart';

class FullHeightPlayer extends StatelessWidget with WatchItMixin {
  const FullHeightPlayer({super.key, required this.playerPosition});

  final PlayerPosition playerPosition;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo == true);
    final active = audio != null;
    final iconColor = isVideo ? Colors.white : theme.colorScheme.onSurface;

    final Widget body;
    if (isVideo) {
      body = isLinux
          // Note: for some reason the video widget crashes if we use the built in controls, so we replicate this with a stack
          ? LinuxFullHeightPlayer(
              iconColor: iconColor,
              active: active,
              playerPosition: playerPosition,
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
        audio: audio,
      );
    }

    return Column(
      spacing: kMediumSpace,
      children: [
        FullHeightPlayerHeaderBar(isVideo: isVideo),
        Expanded(child: body),
      ],
    );
  }
}
