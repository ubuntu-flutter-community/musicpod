import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/theme.dart';
import '../player_mixin.dart';
import '../player_model.dart';

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
                    audio: audio,
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
