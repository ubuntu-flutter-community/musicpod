import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/cover_background.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/sliver_fill_remaining_progress.dart';
import '../../common/view/theme.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../local_audio_model.dart';
import 'album_page.dart';
import 'local_cover.dart';

class AlbumsView extends StatelessWidget with WatchItMixin {
  const AlbumsView({
    super.key,
    required this.albums,
    this.noResultMessage,
    this.noResultIcon,
  });

  final List<String>? albums;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context) {
    if (albums == null) {
      return const SliverFillRemainingProgress();
    }

    if (albums!.isEmpty) {
      return SliverFillNoSearchResultPage(
        icon: noResultIcon,
        message: noResultMessage,
      );
    }

    watchPropertyValue((LibraryModel m) => m.pinnedAlbums.hashCode);
    final pinnedAlbums = di<LibraryModel>()
        .pinnedAlbums
        .entries
        .map((e) => e.value.firstOrNull?.album);
    final sortedAlbums = [
      ...albums!.where((e) => pinnedAlbums.contains(e)),
      ...albums!.where((e) => !pinnedAlbums.contains(e)),
    ];

    return SliverGrid.builder(
      itemCount: sortedAlbums.length,
      gridDelegate: audioCardGridDelegate,
      itemBuilder: (context, index) {
        final album = sortedAlbums.elementAt(index);
        return AlbumCard(
          key: ValueKey(album),
          album: album,
        );
      },
    );
  }
}

class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.album});

  final String album;

  @override
  Widget build(BuildContext context) {
    final playerModel = di<PlayerModel>();
    final albumAudios = di<LocalAudioModel>().findAlbum(album);
    const fallback = CoverBackground();

    final id = albumAudios?.firstWhereOrNull((e) => e.albumId != null)?.albumId;
    final path = albumAudios?.firstWhereOrNull((e) => e.path != null)?.path;

    return AudioCard(
      bottom: AudioCardBottom(text: album),
      image: id != null && path != null
          ? LocalCover(
              dimension: audioCardDimension,
              albumId: id,
              path: path,
              fallback: fallback,
            )
          : const CoverBackground(),
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
