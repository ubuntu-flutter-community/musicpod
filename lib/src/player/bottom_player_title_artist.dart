import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common.dart';
import '../../data.dart';
import '../../player.dart';
import 'package:flutter/material.dart';

class BottomPlayerTitleArtist extends ConsumerWidget {
  const BottomPlayerTitleArtist({
    super.key,
    required this.audio,
  });
  final Audio? audio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mpvMetaData =
        ref.watch(playerModelProvider.select((m) => m.mpvMetaData));
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
          onTap: audio == null
              ? null
              : () => onTitleTap(
                    audio: audio!,
                    text: icyTitle,
                    context: context,
                    ref: ref,
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
            onTap: audio == null
                ? null
                : () => onArtistTap(
                      audio: audio!,
                      context: context,
                      ref: ref,
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
