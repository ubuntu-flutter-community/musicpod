import 'package:flutter/material.dart';

import '../../../common.dart';
import '../../../constants.dart';
import '../../../data.dart';
import '../../../get.dart';
import '../../common/sliver_audio_tile_list.dart';
import '../local_audio_model.dart';
import 'artist_page.dart';

class TitlesView extends StatelessWidget {
  const TitlesView({
    super.key,
    required this.audios,
    this.noResultMessage,
    this.noResultIcon,
    required this.classicTiles,
  });

  final Set<Audio>? audios;
  final Widget? noResultMessage, noResultIcon;
  final bool classicTiles;

  @override
  Widget build(BuildContext context) {
    final model = getIt<LocalAudioModel>();

    if (audios == null) {
      return const Center(
        child: Progress(),
      );
    }

    if (audios!.isEmpty) {
      return NoSearchResultPage(
        icons: noResultIcon,
        message: noResultMessage,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: CustomScrollView(
        slivers: [
          SliverAudioTileList(
            audios: audios!,
            audioPageType: AudioPageType.allTitlesView,
            pageId: kLocalAudioPageId,
            onSubTitleTab: (text) {
              final artistAudios = model.findArtist(Audio(artist: text));
              final images = model.findImages(artistAudios ?? {});

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return ArtistPage(
                      images: images,
                      artistAudios: artistAudios,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
