import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicpod/app/common/copy_clipboard_content.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/data/audio.dart';
import 'package:url_launcher/url_launcher.dart';

void onTitleTap({
  required Audio? audio,
  required String? icyTitle,
  required BuildContext context,
  required void Function(AudioType audioType, String text)? onTextTap,
}) {
  if (audio?.audioType == null ||
      audio?.title == null ||
      audio?.audioType == AudioType.podcast) {
    return;
  }

  if (icyTitle?.isNotEmpty == true) {
    Clipboard.setData(ClipboardData(text: icyTitle!));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: kSnackBarWidth,
        duration: kSnackBarDuration,
        content: CopyClipboardContent(text: icyTitle),
      ),
    );
  } else {
    onTextTap?.call(
      audio!.audioType!,
      audio.title!,
    );
  }
}

void onArtistTap({
  required Audio? audio,
  required String? icyTitle,
  required BuildContext context,
  required void Function(AudioType audioType, String text)? onTextTap,
}) {
  if (audio?.audioType == null || audio?.artist == null) {
    return;
  }
  if (audio!.audioType == AudioType.radio && audio.url?.isNotEmpty == true) {
    Clipboard.setData(ClipboardData(text: audio.url!));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: kSnackBarWidth,
        duration: kSnackBarDuration,
        content: CopyClipboardContent(
          text: audio.url!,
          onSearch: () {
            if (audio.url != null) {
              launchUrl(Uri.parse(audio.url!));
            }
          },
        ),
      ),
    );
  } else {
    onTextTap?.call(
      audio.audioType!,
      audio.audioType == AudioType.radio && audio.title != null
          ? audio.title!
          : audio.artist!,
    );
  }
}
