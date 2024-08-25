import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../player_model.dart';
import 'full_height_player_image.dart';

class BlurredFullHeightPlayerImage extends StatelessWidget with WatchItMixin {
  const BlurredFullHeightPlayerImage({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final mpvMetaData = watchPropertyValue((PlayerModel m) => m.mpvMetaData);

    return Opacity(
      key: ValueKey(
        '${audio?.path ?? ''}${mpvMetaData?.icyTitle ?? ''}${audio?.albumArtUrl ?? ''}${audio?.imageUrl ?? ''}',
      ),
      opacity: theme.isLight ? 0.8 : 0.9,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Blur(
          blur: 35,
          colorOpacity: theme.isLight ? 0.6 : 0.7,
          blurColor:
              theme.isLight ? Colors.white : theme.scaffoldBackgroundColor,
          child: FullHeightPlayerImage(
            borderRadius: BorderRadius.zero,
            fit: BoxFit.cover,
            height: size.height,
            width: size.width,
          ),
        ),
      ),
    );
  }
}
