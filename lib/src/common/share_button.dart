import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common.dart';
import '../../data.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.active,
    this.audio,
    this.color,
    this.iconSize,
  });

  final bool active;
  final Audio? audio;
  final Color? color;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final content =
        audio?.url ?? '${audio?.artist ?? ''} - ${audio?.title ?? ''}';
    return IconButton(
      onPressed: !active
          ? null
          : () {
              Clipboard.setData(
                ClipboardData(
                  text: content,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: CopyClipboardContent(
                    text: content,
                    onSearch: audio?.url == null
                        ? null
                        : () {
                            if (audio?.url != null) {
                              launchUrl(Uri.parse(audio?.url ?? ''));
                            }
                          },
                  ),
                ),
              );
            },
      icon: Icon(
        Iconz().share,
        color: color,
        size: iconSize,
      ),
    );
  }
}
