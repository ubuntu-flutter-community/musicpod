import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icy_image.dart';
import '../../common/view/safe_network_image.dart';
import '../../extensions/build_context_x.dart';
import '../player_model.dart';

class SuperNetworkImage extends StatelessWidget with WatchItMixin {
  const SuperNetworkImage({
    super.key,
    required this.height,
    required this.width,
    required this.audio,
    required this.fit,
    required this.fallBackIcon,
    required this.errorIcon,
  });

  final double height;
  final double width;
  final Audio? audio;
  final BoxFit? fit;
  final Widget fallBackIcon;
  final Widget errorIcon;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final mpvMetaData = watchPropertyValue((PlayerModel m) => m.mpvMetaData);

    final safeNetworkImage = SafeNetworkImage(
      url: audio?.imageUrl ?? audio?.albumArtUrl,
      filterQuality: FilterQuality.medium,
      fit: fit ?? BoxFit.scaleDown,
      fallBackIcon: fallBackIcon,
      errorIcon: errorIcon,
      height: height,
      width: width,
    );

    return Container(
      key: ValueKey(
        mpvMetaData?.icyTitle ?? audio?.imageUrl ?? audio?.albumArtUrl,
      ),
      color: theme.cardColor,
      height: height,
      width: width,
      child:
          mpvMetaData?.icyTitle != null && audio?.audioType == AudioType.radio
              ? IcyImage(
                  mpvMetaData: mpvMetaData!,
                  fallBackWidget: safeNetworkImage,
                  height: height,
                  width: width,
                  fit: fit,
                  fallBackImageUrl: audio?.imageUrl,
                )
              : safeNetworkImage,
    );
  }
}
