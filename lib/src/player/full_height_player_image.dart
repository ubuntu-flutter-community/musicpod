import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../theme.dart';
import '../../theme_data_x.dart';

class FullHeightPlayerImage extends StatelessWidget {
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
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    IconData iconData;
    if (audio?.audioType == AudioType.radio) {
      iconData = Iconz().radio;
    } else if (audio?.audioType == AudioType.podcast) {
      iconData = Iconz().podcast;
    } else {
      iconData = Iconz().musicNote;
    }

    Widget image;
    if (audio?.pictureData != null) {
      image = Image.memory(
        audio!.pictureData!,
        height: height ?? fullHeightPlayerImageSize,
        width: width ?? fullHeightPlayerImageSize,
        fit: fit ?? BoxFit.fitHeight,
      );
    } else {
      if (!isOnline) {
        image = Icon(
          iconData,
          size: fullHeightPlayerImageSize * 0.7,
          color: theme.hintColor,
        );
      } else if (audio?.imageUrl != null || audio?.albumArtUrl != null) {
        image = Container(
          height: height ?? fullHeightPlayerImageSize,
          width: width ?? fullHeightPlayerImageSize,
          color: kCardColorNeutral,
          child: SafeNetworkImage(
            url: audio?.imageUrl ?? audio?.albumArtUrl,
            filterQuality: FilterQuality.medium,
            fit: fit ?? BoxFit.scaleDown,
            fallBackIcon: Icon(
              iconData,
              size: fullHeightPlayerImageSize * 0.7,
              color: theme.hintColor,
            ),
            height: height ?? fullHeightPlayerImageSize,
            width: width ?? fullHeightPlayerImageSize,
          ),
        );
      } else {
        image = Container(
          height: height ?? fullHeightPlayerImageSize,
          width: width ?? fullHeightPlayerImageSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                getAlphabetColor(
                  audio?.title ?? audio?.album ?? 'a',
                ).scale(
                  lightness: theme.isLight ? 0 : -0.4,
                  saturation: -0.5,
                ),
                getAlphabetColor(
                  audio?.title ?? audio?.album ?? 'a',
                ).scale(
                  lightness: theme.isLight ? -0.1 : -0.2,
                  saturation: -0.5,
                ),
              ],
            ),
          ),
          child: Icon(
            iconData,
            size: fullHeightPlayerImageSize * 0.7,
            color: contrastColor(
              getAlphabetColor(
                audio?.title ?? audio?.album ?? 'a',
              ),
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: height ?? fullHeightPlayerImageSize,
      width: width ?? fullHeightPlayerImageSize,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        child: image,
      ),
    );
  }
}
