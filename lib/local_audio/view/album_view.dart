import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../local_audio_model.dart';
import 'album_page.dart';
import 'local_cover.dart';

class AlbumsView extends StatelessWidget {
  const AlbumsView({
    super.key,
    required this.albums,
    this.noResultMessage,
    this.noResultIcon,
    required this.sliver,
  });

  final Set<Audio>? albums;
  final Widget? noResultMessage, noResultIcon;
  final bool sliver;

  @override
  Widget build(BuildContext context) {
    if (sliver) {
      if (albums == null) {
        return const SliverToBoxAdapter(
          child: Center(
            child: Progress(),
          ),
        );
      }

      if (albums!.isEmpty) {
        return SliverToBoxAdapter(
          child: NoSearchResultPage(
            icon: noResultIcon,
            message: noResultMessage,
          ),
        );
      }

      return SliverGrid.builder(
        itemCount: albums!.length,
        gridDelegate: audioCardGridDelegate,
        itemBuilder: itemBuilder,
      );
    } else {
      if (albums == null) {
        return const Center(
          child: Progress(),
        );
      }

      if (albums!.isEmpty) {
        return NoSearchResultPage(
          icon: noResultIcon,
          message: noResultMessage,
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: GridView.builder(
              padding: getAdaptiveHorizontalPadding(constraints: constraints),
              itemCount: albums!.length,
              gridDelegate: audioCardGridDelegate,
              itemBuilder: itemBuilder,
            ),
          );
        },
      );
    }
  }

  Widget itemBuilder(context, index) {
    final audio = albums!.elementAt(index);
    return AlbumCard(audio: audio);
  }
}

class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context) {
    final playerModel = di<PlayerModel>();
    final albumAudios = di<LocalAudioModel>().findAlbum(audio);
    const fallback = CoverBackground();

    final id = audio.albumId;

    return AudioCard(
      bottom: AudioCardBottom(
        text: audio.album?.isNotEmpty == false
            ? context.l10n.unknown
            : audio.album ?? '',
      ),
      image: LocalCover(
        audio: audio,
        fallback: fallback,
      ),
      background: fallback,
      onTap: id == null || albumAudios == null
          ? null
          : () => di<LibraryModel>().push(
                builder: (context) => AlbumPage(id: id, album: albumAudios),
                pageId: id,
              ),
      onPlay: albumAudios == null || albumAudios.isEmpty || id == null
          ? null
          : () => playerModel.startPlaylist(
                audios: albumAudios,
                listName: id,
              ),
    );
  }
}

class CoverBackground extends StatelessWidget {
  const CoverBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/media-optical.png',
      height: kAudioCardDimension,
      width: kAudioCardDimension,
    );
  }
}
