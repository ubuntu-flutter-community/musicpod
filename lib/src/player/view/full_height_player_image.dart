import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../../app.dart';
import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../constants.dart';
import '../../../data.dart';
import '../../../get.dart';
import '../../../globals.dart';
import '../../../radio.dart';
import '../../../theme.dart';
import '../../../theme_data_x.dart';
import 'super_network_image.dart';

class FullHeightPlayerImage extends StatelessWidget with WatchItMixin {
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
  final BorderRadius? borderRadius;

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

    final fallBackImage = Container(
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

    Widget image;
    if (audio?.pictureData != null) {
      image = Image.memory(
        audio!.pictureData!,
        height: height ?? fullHeightPlayerImageSize,
        width: width ?? fullHeightPlayerImageSize,
        fit: fit ?? BoxFit.fitHeight,
      );
    } else {
      if (audio?.path == null && isOnline) {
        image = SuperNetworkImage(
          height: height ?? fullHeightPlayerImageSize,
          width: width ?? fullHeightPlayerImageSize,
          audio: audio,
          fit: fit,
          fallBackIcon: fallBackImage,
          errorIcon: fallBackImage,
          onGenreTap: (genre) => getIt<RadioModel>().init().then(
            (_) {
              getIt<AppModel>().setFullScreen(false);
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) {
                    return RadioSearchPage(
                      radioSearch: RadioSearch.tag,
                      searchQuery: genre.toLowerCase(),
                    );
                  },
                ),
              );
            },
          ),
        );
      } else {
        image = fallBackImage;
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
