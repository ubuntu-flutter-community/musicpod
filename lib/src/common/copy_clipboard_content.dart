import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';

import '../l10n/l10n.dart';

class CopyClipboardContent extends StatelessWidget {
  const CopyClipboardContent({
    super.key,
    required this.text,
    this.onSearch,
  });

  final String? text;
  final void Function()? onSearch;

  @override
  Widget build(BuildContext context) {
    String? artist;
    String? title;
    if (text != null) {
      final split = text!.split('-');

      //https://open.spotify.com/search/artist:Magnetic%20Ghost%20track:Sleeping%20Is%20Believing
      if (split.length == 2) {
        artist = split.first.replaceAll(' ', '%20');
        title = split.last;
      }
    }

    var spotifyButton = IconButton(
      tooltip: context.l10n.search,
      onPressed: () => launchUrl(
        Uri.parse(
          'https://open.spotify.com/search/artist:${artist!}%20track:${title!}',
        ),
      ),
      icon: Icon(
        TablerIcons.brand_spotify,
        color: Colors.white.withOpacity(0.9),
      ),
    );

    final searchButton = IconButton(
      tooltip: context.l10n.search,
      onPressed: onSearch ??
          () => launchUrl(
                Uri.parse(
                  'https://music.youtube.com/search?q=${text!}',
                ),
              ),
      icon: Icon(
        onSearch != null ? YaruIcons.globe : TablerIcons.brand_youtube,
        color: Colors.white.withOpacity(0.9),
      ),
    );

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
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  text!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (artist?.isNotEmpty == true && title?.isNotEmpty == true)
            Row(
              children: [
                spotifyButton,
                searchButton,
              ],
            )
          else
            searchButton,
        ],
      ),
    );
  }
}
