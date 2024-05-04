import '../../../common.dart';
import '../../../data.dart';
import '../../../get.dart';
import 'package:flutter/material.dart';

import '../../data/audio.dart';
import '../player_model.dart';
import '../player_mixin.dart';

class BottomPlayerTitleArtist extends StatelessWidget
    with WatchItMixin, PlayerMixin {
  const BottomPlayerTitleArtist({
    super.key,
    required this.audio,
  });
  final Audio? audio;

  @override
  Widget build(BuildContext context) {
    final icyTitle =
        watchPropertyValue((PlayerModel m) => m.mpvMetaData?.icyTitle);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(4),
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
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(4),
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
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}
