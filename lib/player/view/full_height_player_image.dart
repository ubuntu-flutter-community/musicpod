import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../local_audio/view/local_cover.dart';
import '../player_model.dart';
import 'player_fall_back_image.dart';
import 'player_remote_source_image.dart';

class FullHeightPlayerImage extends StatelessWidget with WatchItMixin {
  const FullHeightPlayerImage({
    super.key,
    this.fit,
    this.height,
    this.width,
    this.borderRadius,
    this.emptyFallBack = false,
  });

  final BoxFit? fit;
  final double? height, width;
  final BorderRadius? borderRadius;
  final bool emptyFallBack;

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    final size = context.isPortrait
        ? fullHeightPlayerImageSize
        : isMobile
        ? fullHeightPlayerImageSize / 3
        : fullHeightPlayerImageSize;
    final theHeight = height ?? size;
    final theWidth = width ?? size;

    final fallBackImage = PlayerFallBackImage(
      noIcon: emptyFallBack,
      audioType: audio?.audioType,
      height: theHeight,
      width: theWidth,
    );

    Widget image;
    if (audio?.canHaveLocalCover == true) {
      image = LocalCover(
        key: ValueKey(audio!.albumId!),
        albumId: audio.albumId!,
        path: audio.path!,
        width: theWidth,
        height: theHeight,
        fit: fit ?? BoxFit.fitHeight,
        fallback: fallBackImage,
      );
    } else {
      image = PlayerRemoteSourceImage(
        height: theHeight,
        width: theWidth,
        fit: fit,
        fallBackIcon: fallBackImage,
        errorIcon: fallBackImage,
      );
    }

    return SizedBox(
      height: theHeight,
      width: theWidth,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: image,
        ),
      ),
    );
  }
}
