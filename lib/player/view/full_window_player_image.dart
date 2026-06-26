import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/ui_constants.dart';
import '../../local_audio/view/local_cover.dart';
import '../manager/player_manager.dart';
import 'player_fall_back_image.dart';
import 'player_remote_source_image.dart';

class FullWindowPlayerImage extends StatelessWidget with WatchItMixin {
  const FullWindowPlayerImage({
    super.key,
    this.fit,
    this.dimension,
    this.borderRadius,
    this.emptyFallBack = false,
  });

  final BoxFit? fit;
  final double? dimension;
  final BorderRadius? borderRadius;
  final bool emptyFallBack;

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerManager m) => m.audio);

    final fallBackImage = PlayerFallBackImage(
      noIcon: emptyFallBack,
      audioType: audio?.audioType,
      height: dimension ?? kFullWindowPlayerImageSize,
      width: dimension ?? kFullWindowPlayerImageSize,
    );

    Widget image;
    if (audio?.canHaveLocalCover == true) {
      image = LocalCover(
        key: ValueKey(audio!.albumDbId!),
        albumId: audio.albumDbId!,
        dimension: dimension ?? kFullWindowPlayerImageSize,
        fit: fit ?? BoxFit.fitHeight,
        fallback: fallBackImage,
      );
    } else {
      image = PlayerRemoteSourceImage(
        height: dimension ?? kFullWindowPlayerImageSize,
        width: dimension ?? kFullWindowPlayerImageSize,
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
