import '../../common.dart';
import '../../data.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
    final theme = Theme.of(context);
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
        return SizedBox(
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
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              iconData,
              size: 50,
              color: theme.hintColor,
            ),
          ),
        );
      }
    }
  }
}
