import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/app_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/view/local_cover.dart';
import '../player_model.dart';
import 'player_fall_back_image.dart';
import 'player_remote_source_image.dart';

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
      audio: audio,
      height: size,
      width: size,
    );

    if (audio?.hasPathAndId == true) {
      child = LocalCover(
        key: ValueKey(audio!.path),
        albumId: audio!.albumId!,
        path: audio!.path!,
        fit: BoxFit.cover,
        dimension: size,
        fallback: fallBackImage,
      );
    } else {
      child = PlayerRemoteSourceImage(
        height: size,
        width: size,
        fit: BoxFit.cover,
        fallBackIcon: fallBackImage,
        errorIcon: fallBackImage,
      );
    }

    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
        if (watchStream((PlayerModel s) => s.onlineArtError).data != null &&
            audio?.audioType == AudioType.radio)
          Positioned(
            bottom: 5,
            right: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Tooltip(
                message: context.l10n.onlineArtError,
                child: Icon(Iconz.warning, color: Colors.yellowAccent),
              ),
            ),
          ),
      ],
    );
  }
}
