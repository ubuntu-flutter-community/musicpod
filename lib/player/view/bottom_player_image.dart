import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/app_model.dart';
import '../../common/data/audio.dart';
import '../../local_audio/view/local_cover.dart';
import 'player_fall_back_image.dart';
import 'super_network_image.dart';

class BottomPlayerImage extends StatelessWidget with WatchItMixin {
  const BottomPlayerImage({
    super.key,
    this.audio,
    required this.size,
    this.isVideo,
    required this.videoController,
    required this.isOnline,
  });
  final Audio? audio;
  final double size;
  final bool? isVideo;
  final VideoController videoController;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    if (isVideo == true) {
      return RepaintBoundary(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => di<AppModel>().setFullWindowMode(true),
            child: Video(
              height: size,
              width: size,
              filterQuality: FilterQuality.medium,
              controller: videoController,
              controls: (state) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    }

    Widget child;

    final fallBackImage = PlayerFallBackImage(
      key: const ValueKey(0),
      audio: audio,
      height: size,
      width: size,
    );

    if (audio != null && audio?.audioType == AudioType.local) {
      child = LocalCover(
        key: ValueKey(audio?.path),
        albumId: audio!.albumId,
        path: audio!.path,
        fit: BoxFit.cover,
        dimension: size,
        fallback: fallBackImage,
      );
    } else if (audio?.albumArtUrl != null || audio?.imageUrl != null) {
      child = SuperNetworkImage(
        key: ValueKey(audio?.albumArtUrl ?? audio?.imageUrl),
        height: size,
        width: size,
        audio: audio,
        fit: BoxFit.cover,
        fallBackIcon: fallBackImage,
        errorIcon: fallBackImage,
      );
    } else {
      child = fallBackImage;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: child,
    );
  }
}
