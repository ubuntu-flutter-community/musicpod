import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/sliver_audio_tile_list.dart';
import '../../constants.dart';
import '../../library/library_model.dart';
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
    final model = di<LocalAudioModel>();

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

              di<LibraryModel>().push(
                builder: (_) => ArtistPage(
                  images: images,
                  artistAudios: artistAudios,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
