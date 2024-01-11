import 'dart:typed_data';

import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../local_audio.dart';
import '../l10n/l10n.dart';

class ArtistsView extends StatelessWidget {
  const ArtistsView({
    super.key,
    this.artists,
    required this.findArtist,
    required this.findImages,
  });

  final Set<Audio>? artists;

  final Set<Audio>? Function(Audio, [AudioFilter]) findArtist;
  final Set<Uint8List>? Function(Set<Audio>) findImages;

  @override
  Widget build(BuildContext context) {
    if (artists == null) {
      return const Center(
        child: Progress(),
      );
    }

    if (artists!.isEmpty) {
      return NoSearchResultPage(
        icons: const AnimatedEmoji(AnimatedEmojis.eyes),
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.noLocalTitlesFound),
            const ShopRecommendations(),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: GridView.builder(
        itemCount: artists!.length,
        padding: gridPadding,
        shrinkWrap: true,
        gridDelegate: kDiskGridDelegate,
        itemBuilder: (context, index) {
          final artistAudios = findArtist(
            artists!.elementAt(index),
          );
          final images = findImages(artistAudios ?? {});

          final artistname =
              artists!.elementAt(index).artist ?? context.l10n.unknown;

          return YaruSelectableContainer(
            selected: false,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ArtistPage(
                    images: images,
                    artistAudios: artistAudios,
                  );
                },
              ),
            ),
            borderRadius: BorderRadius.circular(300),
            child: RoundImageContainer(
              image: images?.firstOrNull,
              text: artistname.isNotEmpty ? artistname : context.l10n.unknown,
            ),
          );
        },
      ),
    );
  }
}
