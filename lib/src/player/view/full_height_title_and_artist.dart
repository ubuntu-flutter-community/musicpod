import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../data.dart';
import '../player_model.dart';
import '../player_mixin.dart';

class FullHeightTitleAndArtist extends StatelessWidget
    with WatchItMixin, PlayerMixin {
  const FullHeightTitleAndArtist({
    super.key,
    required this.audio,
  });

  final Audio? audio;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final icyTitle =
        watchPropertyValue((PlayerModel m) => m.mpvMetaData?.icyTitle);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: audio == null
              ? null
              : () => onTitleTap(
                    audio: audio!,
                    text: icyTitle,
                    context: context,
                  ),
          child: Tooltip(
            message: getTitle(audio: audio, icyTitle: icyTitle),
            child: Text(
              getTitle(audio: audio, icyTitle: icyTitle),
              style: TextStyle(
                fontWeight: largeTextWeight,
                fontSize: 30,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: audio == null
              ? null
              : () => onArtistTap(
                    audio: audio!,
                    context: context,
                  ),
          child: Tooltip(
            message: getSubTitle(audio),
            child: Text(
              getSubTitle(audio),
              style: TextStyle(
                fontWeight: smallTextFontWeight,
                fontSize: 20,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}
