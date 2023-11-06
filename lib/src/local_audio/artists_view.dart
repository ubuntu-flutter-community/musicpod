import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../local_audio.dart';
import '../common/common_widgets.dart';
import '../l10n/l10n.dart';

class ArtistsView extends StatelessWidget {
  const ArtistsView({
    super.key,
    this.artists,
    required this.showWindowControls,
    this.onTextTap,
    required this.findArtist,
    required this.findImages,
  });

  final Set<Audio>? artists;
  final bool showWindowControls;

  final void Function({required String text, required AudioType audioType})?
      onTextTap;
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
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.noLocalTitlesFound),
            const ShopRecommendations(),
          ],
        ),
      );
    }

    return GridView.builder(
      itemCount: artists!.length,
      padding: const EdgeInsets.all(kYaruPagePadding),
      shrinkWrap: true,
      gridDelegate: kDiskGridDelegate,
      itemBuilder: (context, index) {
        final artistAudios = findArtist(
          artists!.elementAt(index),
        );
        final images = findImages(artistAudios ?? {});

        final artistname = artists!.elementAt(index).artist ?? 'unknown';

        return YaruSelectableContainer(
          selected: false,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ArtistPage(
                  onTextTap: ({required audioType, required text}) {
                    onTextTap?.call(text: text, audioType: audioType);
                    Navigator.of(context).maybePop();
                  },
                  images: images,
                  artistAudios: artistAudios,
                  showWindowControls: showWindowControls,
                );
              },
            ),
          ),
          borderRadius: BorderRadius.circular(300),
          child:
              RoundImageContainer(image: images?.firstOrNull, text: artistname),
        );
      },
    );
  }
}
