import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/sliver_fill_remaining_progress.dart';
import '../../common/view/theme.dart';
import '../../extensions/string_x.dart';
import '../../library/library_model.dart';
import 'album_card.dart';

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
