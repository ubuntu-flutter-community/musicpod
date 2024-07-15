import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../library/library_model.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/radio_search.dart';
import '../../radio/view/radio_search_page.dart';
import 'super_network_image.dart';

class BottomPlayerImage extends StatelessWidget with WatchItMixin {
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
    if (isVideo == true) {
      return RepaintBoundary(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => di<AppModel>().setFullWindowMode(true),
            child: Video(
              height: size,
              width: size,
              filterQuality: FilterQuality.medium,
              controller: videoController,
              controls: (state) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    }

    const iconSize = 40.0;
    final theme = context.t;
    IconData iconData;
    if (audio?.audioType == AudioType.radio) {
      iconData = Iconz().radio;
    } else if (audio?.audioType == AudioType.podcast) {
      iconData = Iconz().podcast;
    } else {
      iconData = Iconz().musicNote;
    }

    final fallBackImage = Center(
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

    if (audio?.pictureData != null) {
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
    }

    if (audio?.albumArtUrl != null || audio?.imageUrl != null) {
      return SuperNetworkImage(
        height: size,
        width: size,
        audio: audio,
        fit: BoxFit.cover,
        fallBackIcon: fallBackImage,
        errorIcon: fallBackImage,
        onGenreTap: (genre) => di<RadioModel>().init().then(
              (_) => di<LibraryModel>().push(
                builder: (_) => RadioSearchPage(
                  radioSearch: RadioSearch.tag,
                  searchQuery: genre.toLowerCase(),
                ),
                pageId: kRadioPageId,
              ),
            ),
      );
    }

    return fallBackImage;
  }
}
