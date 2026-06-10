import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../player_manager.dart';
import 'full_window_video_player.dart';
import 'full_window_player_body.dart';
import 'full_window_player_header_bar.dart';
import 'player_view.dart';

class FullWindowPlayer extends StatelessWidget with WatchItMixin {
  const FullWindowPlayer({super.key, required this.playerPosition});

  final PlayerPosition playerPosition;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final audio = watchPropertyValue((PlayerManager m) => m.audio);
    final isVideo = watchPropertyValue((PlayerManager m) => m.isVideo == true);
    final active = audio != null;
    final iconColor = isVideo ? Colors.white : theme.colorScheme.onSurface;

    final Widget body;
    if (isVideo || isMobile && !context.isPortrait) {
      body = isLinux
          // Note: for some reason the video widget crashes if we use the built in controls, so we replicate this with a stack
          ? LinuxFullWindowVideoPlayer(
              iconColor: iconColor,
              active: active,
              playerPosition: playerPosition,
            )
          : FullWindowVideoPlayer(
              playerPosition: playerPosition,
              audio: audio,
              controlsActive: active,
            );
    } else {
      body = FullWindowPlayerBody(active: active);
    }

    return Column(
      spacing: isVideo || (isMobile && !context.isPortrait) ? 0 : kMediumSpace,
      children: [
        FullWindowPlayerHeaderBar(
          isVideo: isVideo || (isMobile && !context.isPortrait),
        ),
        Expanded(child: body),
      ],
    );
  }
}
