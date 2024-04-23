import 'package:flutter/material.dart';

import '../../../common.dart';
import '../../../data.dart';
import '../../common/icy_image.dart';

class SuperNetworkImage extends StatelessWidget {
  const SuperNetworkImage({
    super.key,
    required this.height,
    required this.width,
    required this.audio,
    required this.fit,
    required this.iconData,
    required this.theme,
    this.mpvMetaData,
    required this.iconSize,
    this.onGenreTap,
  });

  final double height;
  final double width;
  final Audio? audio;
  final BoxFit? fit;
  final IconData iconData;
  final ThemeData theme;
  final MpvMetaData? mpvMetaData;
  final double iconSize;
  final Function(String genre)? onGenreTap;

  @override
  Widget build(BuildContext context) {
    final safeNetworkImage = SafeNetworkImage(
      url: audio?.imageUrl ?? audio?.albumArtUrl,
      filterQuality: FilterQuality.medium,
      fit: fit ?? BoxFit.scaleDown,
      fallBackIcon: Icon(
        iconData,
        size: iconSize,
        color: theme.hintColor,
      ),
      errorIcon: Icon(
        iconData,
        size: iconSize,
        color: theme.hintColor,
      ),
      height: height,
      width: width,
    );

    return Container(
      key: ValueKey(mpvMetaData?.icyTitle),
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
                  onGenreTap: onGenreTap,
                  fallBackImageUrl: audio?.imageUrl,
                )
              : safeNetworkImage,
    );
  }
}
