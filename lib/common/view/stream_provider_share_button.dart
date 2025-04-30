import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/app_model.dart';
import '../../l10n/l10n.dart';
import 'icons.dart';
import 'ui_constants.dart';

class StreamProviderShareButton extends StatelessWidget {
  const StreamProviderShareButton({
    super.key,
    this.onSearch,
    required this.text,
    required this.streamProvider,
    this.color,
    this.tile = false,
  });

  final void Function()? onSearch;
  final String? text;
  final StreamProvider streamProvider;
  final Color? color;
  final bool tile;

  @override
  Widget build(BuildContext context) {
    final iconData = switch (streamProvider) {
      StreamProvider.appleMusic => TablerIcons.brand_apple,
      StreamProvider.spotify => TablerIcons.brand_spotify,
      StreamProvider.youTubeMusic => TablerIcons.brand_youtube,
      StreamProvider.amazonMusic => TablerIcons.brand_amazon,
      StreamProvider.amazon => TablerIcons.shopping_bag
    };

    final tooltip = switch (streamProvider) {
      StreamProvider.appleMusic => 'Apple Music',
      StreamProvider.spotify => 'Spotify',
      StreamProvider.youTubeMusic => 'YouTube Music',
      StreamProvider.amazonMusic => 'Amazon Music',
      StreamProvider.amazon => 'Amazon'
    };

    final clearedText =
        text?.replaceAll(RegExp(r"[:/?#\[\]@!$&'()*+,;=%]"), ' ') ?? '';

    String address = buildAddress(clearedText.trim());

    if (tile) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: kLargestSpace,
          vertical: kSmallestSpace,
        ),
        minLeadingWidth: 2 * kLargestSpace,
        leading: Icon(iconData),
        title: Text('$tooltip ${context.l10n.search}'),
        onTap: () => launchUrl(
          Uri.parse(
            address,
          ),
        ),
      );
    }

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
          onSearch != null ? Iconz.globe : iconData,
          color: color,
        ),
      ),
    );
  }

  String buildAddress(String query) {
    final address = switch (streamProvider) {
      StreamProvider.youTubeMusic =>
        'https://music.youtube.com/search?q=$query',
      StreamProvider.appleMusic =>
        'https://music.apple.com/us/search?term=$query',
      StreamProvider.spotify => 'https://open.spotify.com/search/$query',
      StreamProvider.amazonMusic =>
        'https://music.amazon.${getAmazonSuffix()}/search/$query?filter=IsLibrary%7Cfalse&sc=none',
      StreamProvider.amazon =>
        'https://www.amazon.${getAmazonSuffix()}/s?k=$query&i=digital-music'
    };
    return address;
  }

  String getAmazonSuffix() {
    final countryCode = di<AppModel>().countryCode;
    return switch (countryCode) {
      'au' => 'com.au',
      'at' => 'at',
      'br' => 'com.br',
      'ca' => 'ca',
      'fr' => 'fr',
      'de' => 'de',
      'in' => 'in',
      'it' => 'it',
      'jp' => 'co.jp',
      'mx' => 'com.mx',
      'nl' => 'nl',
      'pl' => 'pl',
      'sg' => 'com.sg',
      'es' => 'es',
      'ae' => 'ae',
      'gb' || 'ie' => 'co.uk',
      'us' => 'com',
      _ => 'com',
    };
  }
}

class StreamProviderRow extends StatelessWidget {
  const StreamProviderRow({
    super.key,
    this.text,
    this.onSearch,
    this.spacing = 0.0,
    this.iconColor,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  final String? text;
  final void Function()? onSearch;

  final double spacing;
  final Color? iconColor;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
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
        if (onSearch == null)
          StreamProviderShareButton(
            color: iconColor,
            text: text,
            streamProvider: StreamProvider.amazonMusic,
          ),
        if (onSearch == null)
          StreamProviderShareButton(
            color: iconColor,
            text: text,
            streamProvider: StreamProvider.amazon,
          ),
      ],
    );
  }
}

enum StreamProvider {
  youTubeMusic,
  spotify,
  appleMusic,
  amazonMusic,
  amazon,
}
