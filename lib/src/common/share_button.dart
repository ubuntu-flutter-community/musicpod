import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicpod/src/common/common_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common.dart';
import '../../data.dart';
import 'icons.dart';

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
                  width: snackBarWidth,
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
      icon: Icon(Iconz().share),
    );
  }
}
