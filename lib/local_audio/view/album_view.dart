import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/sliver_fill_remaining_progress.dart';
import '../../common/view/theme.dart';
import '../manager/pinned_album_ids_manager.dart';
import 'album_card.dart';

class AlbumsView extends ConsumerWidget {
  const AlbumsView({
    super.key,
    required this.albumIDs,
    this.noResultMessage,
    this.noResultIcon,
  });

  final List<int>? albumIDs;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (albumIDs == null) {
      return const SliverFillRemainingProgress();
    }

    if (albumIDs!.isEmpty) {
      return SliverNoSearchResultPage(
        icon: noResultIcon,
        message: noResultMessage,
      );
    }

    final pinnedAlbumIDs =
        ref.watch(pinnedAlbumIDsManagerProvider).value ?? [];

    final pinned = albumIDs?.where((e) => pinnedAlbumIDs.contains(e)) ?? [];
    final notPinned =
        albumIDs?.where((e) => !pinnedAlbumIDs.contains(e)) ?? [];
    final sortedAlbums = [...pinned, ...notPinned];

    return SliverGrid.builder(
      itemCount: sortedAlbums.length,
      gridDelegate: audioCardGridDelegate,
      itemBuilder: (context, index) {
        final albumID = sortedAlbums.elementAt(index);
        return AlbumCard(key: ValueKey(albumID), id: albumID);
      },
    );
  }
}
