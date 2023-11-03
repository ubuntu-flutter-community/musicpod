import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicpod/app/common/copy_clipboard_content.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/data/audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, required this.active, this.audio});

  final bool active;
  final Audio? audio;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: !active || audio?.url == null
          ? null
          : () {
              Clipboard.setData(ClipboardData(text: audio!.url!));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  width: kSnackBarWidth,
                  behavior: SnackBarBehavior.floating,
                  content: CopyClipboardContent(
                    text: audio?.url,
                    onSearch: () {
                      if (audio?.url != null) {
                        launchUrl(Uri.parse(audio!.url!));
                      }
                    },
                  ),
                ),
              );
            },
      icon: const Icon(YaruIcons.share),
    );
  }
}
