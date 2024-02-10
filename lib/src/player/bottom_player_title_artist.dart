import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../../common.dart';
import '../../data.dart';
import '../../player.dart';

class BottomPlayerTitleArtist extends StatelessWidget {
  const BottomPlayerTitleArtist({
    super.key,
    required this.audio,
  });
  final Audio? audio;

  @override
  Widget build(BuildContext context) {
    final mpvMetaData = getService<PlayerService>().mpvMetaData.watch(context);
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => onTitleTap(
            audio: audio,
            text: icyTitle,
            context: context,
          ),
          child: Tooltip(
            message: title,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (audio?.artist?.trim().isNotEmpty == true ||
            icyName?.isNotEmpty == true)
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => onArtistTap(
              audio: audio,
              artist: icyTitle,
              context: context,
            ),
            child: Tooltip(
              message: subTitle,
              child: Text(
                subTitle,
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
