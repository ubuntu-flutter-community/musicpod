import '../../common.dart';
import '../../data.dart';
import '../../player.dart';
import 'package:flutter/material.dart';

class BottomPlayerTitleArtist extends StatelessWidget {
  const BottomPlayerTitleArtist({
    super.key,
    required this.audio,
    required this.onTextTap,
    this.icyTitle,
    this.icyName,
  });

  final Audio? audio;
  final String? icyTitle;
  final String? icyName;
  final void Function(AudioType audioType, String text)? onTextTap;

  @override
  Widget build(BuildContext context) {
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
            onTextTap: onTextTap,
          ),
          child: Tooltip(
            message: icyTitle?.isNotEmpty == true
                ? icyTitle!
                : (audio?.title?.isNotEmpty == true ? audio!.title! : ' '),
            child: Text(
              icyTitle?.isNotEmpty == true
                  ? icyTitle!
                  : (audio?.title?.isNotEmpty == true ? audio!.title! : ' '),
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
              onTextTap: onTextTap,
            ),
            child: Tooltip(
              message: icyName?.isNotEmpty == true
                  ? icyName!
                  : (audio?.artist ?? ' '),
              child: Text(
                icyName?.isNotEmpty == true ? icyName! : (audio?.artist ?? ' '),
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
