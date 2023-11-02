import 'package:flutter/material.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';

class CopyClipboardContent extends StatelessWidget {
  const CopyClipboardContent({
    super.key,
    required this.icyTitle,
  });

  final String? icyTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Text(
                  context.l10n.copiedToClipBoard,
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                Text(
                  icyTitle!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.search,
            onPressed: () => launchUrl(
              Uri.parse(
                'https://music.youtube.com/search?q=${icyTitle!}',
              ),
            ),
            icon: const Icon(
              YaruIcons.globe,
            ),
          ),
        ],
      ),
    );
  }
}
