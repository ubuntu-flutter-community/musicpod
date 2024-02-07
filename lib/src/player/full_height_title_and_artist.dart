import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../data.dart';
import '../../player.dart';

class FullHeightTitleAndArtist extends StatelessWidget {
  const FullHeightTitleAndArtist({
    super.key,
    required this.audio,
  });

  final Audio? audio;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final mpvMetaData = context.select((PlayerModel m) => m.mpvMetaData);
    final icyName = mpvMetaData?.icyName;
    final icyTitle = mpvMetaData?.icyTitle;

    final subTitle = icyName?.isNotEmpty == true
        ? icyName!
        : (audio?.audioType == AudioType.podcast
                ? audio?.album
                : audio?.artist ?? ' ') ??
            '';

    final title = icyTitle?.isNotEmpty == true
        ? icyTitle!
        : (audio?.title?.isNotEmpty == true ? audio!.title! : ' ');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onTitleTap(
            audio: audio,
            text: mpvMetaData?.icyTitle,
            context: context,
          ),
          child: Tooltip(
            message: title,
            child: Text(
              title,
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
          onTap: () => onArtistTap(
            audio: audio,
            artist: mpvMetaData?.icyName,
            context: context,
          ),
          child: Tooltip(
            message: subTitle,
            child: Text(
              subTitle,
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
