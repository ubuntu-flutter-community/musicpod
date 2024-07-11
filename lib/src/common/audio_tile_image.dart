import 'package:flutter/material.dart';

import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../theme.dart';
import '../../theme_data_x.dart';

class AudioTileImage extends StatelessWidget {
  const AudioTileImage({
    super.key,
    this.audio,
    required this.size,
  });
  final Audio? audio;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size / (1.65);
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
        filterQuality: FilterQuality.medium,
        fit: BoxFit.cover,
        audio!.pictureData!,
        height: size,
      );
    } else {
      if (audio?.imageUrl != null || audio?.albumArtUrl != null) {
        image = SafeNetworkImage(
          url: audio?.imageUrl ?? audio?.albumArtUrl,
          height: size,
          fit: BoxFit.cover,
        );
      } else {
        image = Center(
          child: Container(
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
            width: size,
            height: size,
            child: Icon(
              iconData,
              size: iconSize,
              color: contrastColor(
                getAlphabetColor(
                  audio?.title ?? audio?.album ?? 'a',
                ),
              ),
            ),
          ),
        );
      }
    }

    return SizedBox.square(
      dimension: kAudioTrackWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: image,
      ),
    );
  }
}
