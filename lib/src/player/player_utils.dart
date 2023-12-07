import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common.dart';
import '../../data.dart';
import '../../globals.dart';

void onTitleTap({
  required Audio? audio,
  required String? text,
  required BuildContext context,
  required void Function({required String text, required AudioType audioType})
      onTextTap,
}) {
  if (audio?.audioType == null || audio?.title == null) {
    return;
  }

  if (text?.isNotEmpty == true) {
    Clipboard.setData(ClipboardData(text: text!));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: snackBarWidth,
        duration: kSnackBarDuration,
        content: CopyClipboardContent(text: text),
      ),
    );
  } else if ((audio?.audioType == AudioType.radio ||
          audio?.audioType == AudioType.podcast) &&
      audio?.url?.isNotEmpty == true) {
    Clipboard.setData(ClipboardData(text: audio!.url!));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: snackBarWidth,
        duration: kSnackBarDuration,
        content: CopyClipboardContent(
          text: audio.url!,
          onSearch: () {
            if (audio.url != null) {
              launchUrl(Uri.parse(audio.url ?? ''));
            }
          },
        ),
      ),
    );
  } else {
    onTextTap.call(
      audioType: audio!.audioType!,
      text: audio.title!,
    );
    navigatorKey.currentState?.maybePop();
  }
}

void onArtistTap({
  required Audio? audio,
  required String? artist,
  required BuildContext context,
  required void Function({required String text, required AudioType audioType})
      onTextTap,
}) {
  if (audio?.audioType == null || audio?.artist == null) {
    return;
  }
  if (audio!.audioType == AudioType.radio && audio.url?.isNotEmpty == true) {
    Clipboard.setData(ClipboardData(text: audio.url!));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: snackBarWidth,
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
    onTextTap.call(
      audioType: audio.audioType!,
      text: audio.audioType == AudioType.radio && audio.title != null
          ? audio.title!
          : audio.artist!,
    );
    navigatorKey.currentState?.maybePop();
  }
}

String createQueueElement(Audio? audio) {
  final title = audio?.title?.isNotEmpty == true ? audio?.title! : '';
  final artist = audio?.artist?.isNotEmpty == true ? ' • ${audio?.artist}' : '';
  return '$title$artist'.trim();
}
