import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/ui_constants.dart';
import '../../local_audio/view/local_cover.dart';
import '../player_model.dart';
import 'player_fall_back_image.dart';
import 'player_remote_source_image.dart';

class FullWindowPlayerImage extends StatelessWidget with WatchItMixin {
  const FullWindowPlayerImage({
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
      audioType: audio?.audioType,
      height: kFullWindowPlayerImageSize,
      width: kFullWindowPlayerImageSize,
    );

    Widget image;
    if (audio?.canHaveLocalCover == true) {
      image = LocalCover(
        key: ValueKey(audio!.albumDbId!),
        albumId: audio.albumDbId!,
        dimension: kFullWindowPlayerImageSize,
        fit: fit ?? BoxFit.fitHeight,
        fallback: fallBackImage,
      );
    } else {
      image = PlayerRemoteSourceImage(
        height: kFullWindowPlayerImageSize,
        width: kFullWindowPlayerImageSize,
        fit: fit,
        fallBackIcon: fallBackImage,
        errorIcon: fallBackImage,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: image,
      ),
    );
  }
}
