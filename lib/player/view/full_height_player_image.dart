import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants.dart';
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

    final fallBackImage = PlayerFallBackImage(
      noIcon: emptyFallBack,
      audio: audio,
      height: height ?? fullHeightPlayerImageSize,
      width: width ?? fullHeightPlayerImageSize,
    );

    Widget image;
    if (audio?.hasPathAndId == true) {
      image = LocalCover(
        key: ValueKey(audio!.path),
        albumId: audio.albumId!,
        path: audio.path!,
        width: width,
        height: height,
        fit: fit ?? BoxFit.fitHeight,
        fallback: fallBackImage,
      );
    } else {
      image = PlayerRemoteSourceImage(
        height: height ?? fullHeightPlayerImageSize,
        width: width ?? fullHeightPlayerImageSize,
        fit: fit,
        fallBackIcon: fallBackImage,
        errorIcon: fallBackImage,
      );
    }

    return SizedBox(
      height: height ?? fullHeightPlayerImageSize,
      width: width ?? fullHeightPlayerImageSize,
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
