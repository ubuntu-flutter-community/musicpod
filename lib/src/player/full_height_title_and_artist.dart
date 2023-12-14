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
    required this.onTextTap,
  });

  final Audio? audio;
  final void Function({required AudioType audioType, required String text})
      onTextTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final mpvMetaData = context.select((PlayerModel m) => m.mpvMetaData);

    final label = mpvMetaData?.icyTitle.isNotEmpty == true
        ? mpvMetaData!.icyTitle
        : (audio?.title?.isNotEmpty == true ? audio!.title! : '');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onTitleTap(
            audio: audio,
            text: mpvMetaData?.icyTitle,
            context: context,
            onTextTap: onTextTap,
          ),
          child: Tooltip(
            message: label,
            child: Text(
              label,
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
            onTextTap: onTextTap,
          ),
          child: Text(
            mpvMetaData?.icyName.isNotEmpty == true
                ? mpvMetaData!.icyName
                : (audio?.artist ?? ''),
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
      ],
    );
  }
}
