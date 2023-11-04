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
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              StreamProviderShareButton(
                onSearch: onSearch,
                text: text,
                streamProvider: StreamProvider.youTubeMusic,
              ),
              if (onSearch == null)
                StreamProviderShareButton(
                  text: text,
                  streamProvider: StreamProvider.spotify,
                ),
              if (onSearch == null)
                StreamProviderShareButton(
                  text: text,
                  streamProvider: StreamProvider.appleMusic,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class StreamProviderShareButton extends StatelessWidget {
  const StreamProviderShareButton({
    super.key,
    this.onSearch,
    required this.text,
    required this.streamProvider,
  });

  final void Function()? onSearch;
  final String? text;
  final StreamProvider streamProvider;

  @override
  Widget build(BuildContext context) {
    final iconData = switch (streamProvider) {
      StreamProvider.appleMusic => TablerIcons.brand_apple,
      StreamProvider.spotify => TablerIcons.brand_spotify,
      StreamProvider.youTubeMusic => TablerIcons.brand_youtube,
    };

    final tooltip = switch (streamProvider) {
      StreamProvider.appleMusic => 'Apple Music',
      StreamProvider.spotify => 'Spotify',
      StreamProvider.youTubeMusic => 'Apple Music',
    };
    final address = switch (streamProvider) {
      StreamProvider.youTubeMusic => 'https://music.youtube.com/search?q=$text',
      StreamProvider.appleMusic =>
        'https://music.apple.com/us/search?term=$text',
      StreamProvider.spotify => 'https://open.spotify.com/search/$text'
    };
    return IconButton(
      tooltip: onSearch != null
          ? context.l10n.search
          : '$tooltip ${context.l10n.search}',
      onPressed: onSearch ??
          () => launchUrl(
                Uri.parse(
                  address,
                ),
              ),
      icon: Icon(
        onSearch != null ? YaruIcons.globe : iconData,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }
}

enum StreamProvider {
  youTubeMusic,
  spotify,
  appleMusic,
}
