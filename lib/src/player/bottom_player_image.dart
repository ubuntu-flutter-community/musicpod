import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../theme.dart';
import '../../theme_data_x.dart';

class BottomPlayerImage extends StatelessWidget {
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
    final theme = context.t;
    IconData iconData;
    if (audio?.audioType == AudioType.radio) {
      iconData = Iconz().radio;
    } else if (audio?.audioType == AudioType.podcast) {
      iconData = Iconz().podcast;
    } else {
      iconData = Iconz().musicNote;
    }
    if (isVideo == true) {
      return RepaintBoundary(
        child: Video(
          height: size,
          width: size,
          filterQuality: FilterQuality.medium,
          controller: videoController,
          controls: (state) {
            return const SizedBox.shrink();
          },
        ),
      );
    } else if (audio?.pictureData != null) {
      return AnimatedContainer(
        height: size,
        width: size,
        duration: const Duration(milliseconds: 300),
        child: Image.memory(
          filterQuality: FilterQuality.medium,
          fit: BoxFit.cover,
          audio!.pictureData!,
          height: size,
        ),
      );
    } else {
      if (!isOnline) {
        return SizedBox(
          width: size,
          height: size,
          child: Icon(
            iconData,
            size: 50,
            color: theme.hintColor,
          ),
        );
      } else if (audio?.imageUrl != null || audio?.albumArtUrl != null) {
        return Container(
          color: kCardColorNeutral,
          height: size,
          width: size,
          child: SafeNetworkImage(
            errorIcon: Icon(
              iconData,
              size: 50,
              color: theme.hintColor,
            ),
            url: audio?.imageUrl ?? audio?.albumArtUrl,
            filterQuality: FilterQuality.medium,
            fit: BoxFit.scaleDown,
          ),
        );
      } else {
        return Center(
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
              size: 50,
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
  }
}
