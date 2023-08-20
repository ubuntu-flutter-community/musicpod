import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
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
                  width: 500,
                  behavior: SnackBarBehavior.floating,
                  content: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${context.l10n.copiedToClipBoard} ',
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: TextButton(
                          child: Text(
                            audio!.url!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          onPressed: () => launchUrl(Uri.parse(audio!.url!)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
      icon: const Icon(YaruIcons.share),
    );
  }
}
