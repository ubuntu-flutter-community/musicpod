import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/l10n.dart';
import '../data/audio.dart';
import 'copy_clipboard_content.dart';
import 'icons.dart';
import 'snackbars.dart';

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
      tooltip: context.l10n.share,
      onPressed: !active
          ? null
          : () {
              showSnackBar(
                context: context,
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
