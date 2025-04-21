import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
import '../../common/data/audio.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/audio_card_vignette.dart';
import '../../common/view/cover_background.dart';
import '../../common/view/icons.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/sliver_fill_remaining_progress.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/string_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../local_audio_model.dart';
import 'album_page.dart';
import 'local_cover.dart';

class AlbumsView extends StatelessWidget with WatchItMixin {
  const AlbumsView({
    super.key,
    required this.albumIDs,
    this.noResultMessage,
    this.noResultIcon,
  });

  final List<String>? albumIDs;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context) {
    if (albumIDs == null) {
      return const SliverFillRemainingProgress();
    }

    if (albumIDs!.isEmpty) {
      return SliverNoSearchResultPage(
        icon: noResultIcon,
        message: noResultMessage,
      );
    }

    watchPropertyValue((LibraryModel m) => m.favoriteAlbums.hashCode);

    final pinnedAlbumsAlbumKeys = di<LibraryModel>().favoriteAlbums;
    pinnedAlbumsAlbumKeys.sort((a, b) => a.albumOfId.compareTo(b.albumOfId));

    final pinned =
        albumIDs?.where((e) => pinnedAlbumsAlbumKeys.contains(e)) ?? [];
    final notPinned =
        albumIDs?.where((e) => !pinnedAlbumsAlbumKeys.contains(e)) ?? [];
    final sortedAlbums = [
      ...pinned,
      ...notPinned,
    ];

    return SliverGrid.builder(
      itemCount: sortedAlbums.length,
      gridDelegate: audioCardGridDelegate,
      itemBuilder: (context, index) {
        final albumID = sortedAlbums.elementAt(index);
        return AlbumCard(
          key: ValueKey(albumID),
          id: albumID,
          pinned: pinned.contains(albumID),
        );
      },
    );
  }
}

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.id,
    required this.pinned,
  });

  final String id;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final playerModel = di<PlayerModel>();
    final albumAudios = di<LocalAudioModel>().findAlbum(id);
    const fallback = CoverBackground();

    final path = albumAudios?.firstWhereOrNull((e) => e.path != null)?.path;

    return Stack(
      alignment: Alignment.center,
      children: [
        AudioCard(
          bottom: AudioCardBottom(text: id.split(Audio.albumIdSplitter).last),
          image: path != null
              ? LocalCover(
                  dimension: audioCardDimension,
                  albumId: id,
                  path: path,
                  fallback: fallback,
                )
              : const CoverBackground(),
          background: fallback,
          onTap: albumAudios == null
              ? null
              : () => di<LibraryModel>().push(
                    builder: (context) => AlbumPage(id: id),
                    pageId: id,
                  ),
          onPlay: albumAudios == null || albumAudios.isEmpty
              ? null
              : () => playerModel.startPlaylist(
                    audios: albumAudios,
                    listName: id,
                  ),
        ),
        if (pinned)
          Positioned(
            left: AppConfig.isMobilePlatform ? 6 : 5,
            bottom:
                kAudioCardBottomHeight + (AppConfig.isMobilePlatform ? 25 : 13),
            child: AudioCardVignette(
              iconData: Iconz.pinFilled,
              onTap: () => di<LibraryModel>().removeFavoriteAlbum(
                id,
                onFail: () => showSnackBar(
                  context: context,
                  content: Text(context.l10n.cantUnpinEmptyAlbum),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
