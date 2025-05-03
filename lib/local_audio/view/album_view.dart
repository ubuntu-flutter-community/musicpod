import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
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
import '../../extensions/taget_platform_x.dart';
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

class AlbumCard extends StatefulWidget {
  const AlbumCard({
    super.key,
    required this.id,
    required this.pinned,
  });

  final String id;
  final bool pinned;

  @override
  State<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  late Future<String?> _pathFuture;

  @override
  void initState() {
    super.initState();
    _pathFuture = di<LocalAudioModel>().findCoverPath(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    const fallback = CoverBackground();

    return Stack(
      alignment: Alignment.center,
      children: [
        FutureBuilder(
          future: _pathFuture,
          builder: (context, snapshot) {
            final path = snapshot.data;
            return AudioCard(
              bottom: AudioCardBottom(text: widget.id.albumOfId),
              image: AnimatedOpacity(
                opacity: path == null ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: path != null
                    ? LocalCover(
                        dimension: audioCardDimension,
                        albumId: widget.id,
                        path: path,
                        fallback: fallback,
                      )
                    : null,
              ),
              background: fallback,
              onTap: () => di<RoutingManager>().push(
                builder: (context) => AlbumPage(id: widget.id),
                pageId: widget.id,
              ),
              onPlay: () async => di<PlayerModel>().startPlaylist(
                audios: await di<LocalAudioModel>().findAlbum(widget.id) ?? [],
                listName: widget.id,
              ),
            );
          },
        ),
        if (widget.pinned)
          Positioned(
            left: isMobile ? 6 : 5,
            bottom: kAudioCardBottomHeight + (isMobile ? 25 : 13),
            child: AudioCardVignette(
              iconData: Iconz.pinFilled,
              onTap: () => di<LibraryModel>().removeFavoriteAlbum(
                widget.id,
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
