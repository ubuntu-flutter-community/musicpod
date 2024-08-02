import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../constants.dart';
import '../../local_audio/view/local_cover.dart';
import 'player_fall_back_image.dart';
import 'super_network_image.dart';

class FullHeightPlayerImage extends StatelessWidget with WatchItMixin {
  const FullHeightPlayerImage({
    super.key,
    this.audio,
    required this.isOnline,
    this.fit,
    this.height,
    this.width,
    this.borderRadius,
  });

  final Audio? audio;
  final bool isOnline;
  final BoxFit? fit;
  final double? height, width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final fallBackImage = PlayerFallBackImage(
      key: const ValueKey(0),
      audio: audio,
      height: height ?? fullHeightPlayerImageSize,
      width: width ?? fullHeightPlayerImageSize,
    );

    Widget image;
    if (audio != null && audio?.audioType == AudioType.local) {
      image = LocalCover(
        key: ValueKey(audio?.path),
        audio: audio!,
        width: width,
        height: height,
        fit: fit ?? BoxFit.fitHeight,
        fallback: fallBackImage,
      );
    } else {
      if (audio?.albumArtUrl != null || audio?.imageUrl != null) {
        image = SuperNetworkImage(
          key: ValueKey(audio?.imageUrl ?? audio?.albumArtUrl),
          height: height ?? fullHeightPlayerImageSize,
          width: width ?? fullHeightPlayerImageSize,
          audio: audio,
          fit: fit,
          fallBackIcon: fallBackImage,
          errorIcon: fallBackImage,
        );
      } else {
        image = fallBackImage;
      }
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
