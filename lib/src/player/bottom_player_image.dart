import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';

class BottomPlayerImage extends StatelessWidget {
  const BottomPlayerImage({
    super.key,
    this.audio,
    required this.size,
    this.isVideo,
    required this.videoController,
    required this.isOnline,
    required this.setFullScreen,
  });
  final Audio? audio;
  final double size;
  final bool? isVideo;
  final VideoController videoController;
  final bool isOnline;
  final void Function() setFullScreen;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final Widget image;
    IconData iconData;
    if (audio?.audioType == AudioType.radio) {
      iconData = Iconz().radio;
    } else if (audio?.audioType == AudioType.podcast) {
      iconData = Iconz().podcast;
    } else {
      iconData = Iconz().musicNote;
    }
    if (isVideo == true) {
      image = RepaintBoundary(
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
      image = AnimatedContainer(
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
        image = SizedBox(
          width: size,
          height: size,
          child: Icon(
            iconData,
            size: 50,
            color: theme.hintColor,
          ),
        );
      } else if (audio?.imageUrl != null || audio?.albumArtUrl != null) {
        image = Container(
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
        image = Center(
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
    return MouseRegion(
      cursor: MaterialStateMouseCursor.clickable,
      child: GestureDetector(
        onTap: () => setFullScreen(),
        child: image,
      ),
    );
  }
}
