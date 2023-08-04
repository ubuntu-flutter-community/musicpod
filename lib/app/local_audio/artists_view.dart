import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/app/common/round_image_container.dart';
import 'package:musicpod/app/local_audio/artist_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ArtistsView extends StatelessWidget {
  const ArtistsView({
    super.key,
    required this.similarArtistsSearchResult,
    required this.showWindowControls,
    this.onTextTap,
    required this.findArtist,
    required this.findImages,
  });

  final Set<Audio> similarArtistsSearchResult;
  final bool showWindowControls;

  final void Function({required String text, required AudioType audioType})?
      onTextTap;
  final Set<Audio>? Function(Audio, [AudioFilter]) findArtist;
  final Set<Uint8List>? Function(Set<Audio>) findImages;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: similarArtistsSearchResult.length,
      padding: const EdgeInsets.all(kYaruPagePadding),
      shrinkWrap: true,
      gridDelegate: kImageGridDelegate,
      itemBuilder: (context, index) {
        final artistAudios = findArtist(
          similarArtistsSearchResult.elementAt(index),
        );
        final images = findImages(artistAudios ?? {});

        final artistname =
            similarArtistsSearchResult.elementAt(index).artist ?? 'unknown';

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
