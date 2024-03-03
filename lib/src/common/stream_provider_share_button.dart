import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'icons.dart';
import '../l10n/l10n.dart';

class StreamProviderShareButton extends StatelessWidget {
  const StreamProviderShareButton({
    super.key,
    this.onSearch,
    required this.text,
    required this.streamProvider,
    this.color,
  });

  final void Function()? onSearch;
  final String? text;
  final StreamProvider streamProvider;
  final Color? color;

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

    final clearedText =
        text?.replaceAll(RegExp(r"[:/?#\[\]@!$&'()*+,;=%]"), ' ') ?? '';

    final address = switch (streamProvider) {
      StreamProvider.youTubeMusic =>
        'https://music.youtube.com/search?q=$clearedText',
      StreamProvider.appleMusic =>
        'https://music.apple.com/us/search?term=$clearedText',
      StreamProvider.spotify => 'https://open.spotify.com/search/$clearedText'
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
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Icon(
          onSearch != null ? Iconz().globe : iconData,
          color: color,
        ),
      ),
    );
  }
}

class StreamProviderRow extends StatelessWidget {
  const StreamProviderRow({
    super.key,
    this.text,
    this.onSearch,
    this.spacing = 0.0,
    this.iconColor,
  });

  final String? text;
  final void Function()? onSearch;

  final double spacing;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StreamProviderShareButton(
          color: iconColor,
          onSearch: onSearch,
          text: text,
          streamProvider: StreamProvider.youTubeMusic,
        ),
        if (onSearch == null && spacing > 0)
          SizedBox(
            width: spacing,
          ),
        if (onSearch == null)
          StreamProviderShareButton(
            color: iconColor,
            text: text,
            streamProvider: StreamProvider.spotify,
          ),
        if (onSearch == null && spacing > 0)
          SizedBox(
            width: spacing,
          ),
        if (onSearch == null)
          StreamProviderShareButton(
            color: iconColor,
            text: text,
            streamProvider: StreamProvider.appleMusic,
          ),
      ],
    );
  }
}

enum StreamProvider {
  youTubeMusic,
  spotify,
  appleMusic,
}
