import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';

import '../l10n/l10n.dart';

class StreamProviderShareButton extends StatelessWidget {
  const StreamProviderShareButton({
    super.key,
    this.onSearch,
    required this.text,
    required this.streamProvider,
    this.padding = EdgeInsets.zero,
  });

  final void Function()? onSearch;
  final String? text;
  final StreamProvider streamProvider;
  final EdgeInsetsGeometry padding;

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
      StreamProvider.youTubeMusic => 'YouTube Music',
    };
    final address = switch (streamProvider) {
      StreamProvider.youTubeMusic => 'https://music.youtube.com/search?q=$text',
      StreamProvider.appleMusic =>
        'https://music.apple.com/us/search?term=$text',
      StreamProvider.spotify => 'https://open.spotify.com/search/$text'
    };
    return Padding(
      padding: padding,
      child: IconButton(
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
      ),
    );
  }
}

class StreamProviderRow extends StatelessWidget {
  const StreamProviderRow({
    super.key,
    this.text,
    this.padding = const EdgeInsets.only(left: 10),
    this.onSearch,
    this.spacing = EdgeInsets.zero,
  });

  final String? text;
  final void Function()? onSearch;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          StreamProviderShareButton(
            padding: spacing,
            onSearch: onSearch,
            text: text,
            streamProvider: StreamProvider.youTubeMusic,
          ),
          if (onSearch == null)
            StreamProviderShareButton(
              padding: spacing,
              text: text,
              streamProvider: StreamProvider.spotify,
            ),
          if (onSearch == null)
            StreamProviderShareButton(
              padding: spacing,
              text: text,
              streamProvider: StreamProvider.appleMusic,
            ),
        ],
      ),
    );
  }
}

enum StreamProvider {
  youTubeMusic,
  spotify,
  appleMusic,
}
