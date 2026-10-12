import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../manager/current_audio_manager.dart';
import '../manager/is_video_manager.dart';
import 'full_window_player_body.dart';
import 'full_window_player_header_bar.dart';
import 'full_window_video_player.dart';
import 'player_view.dart';

class FullWindowPlayer extends ConsumerWidget {
  const FullWindowPlayer({super.key, required this.playerPosition});

  final PlayerPosition playerPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    final audio = ref.watch(currentAudioManagerProvider);
    final isVideo = ref.watch(isVideoManagerProvider);
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
