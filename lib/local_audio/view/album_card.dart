import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data/play_anywhere_param.dart';
import '../../app/play_anywhere_manager.dart';
import '../../app/routing_manager.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/audio_card_vignette.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/cover_background.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../manager/find_album_name_manager.dart';
import '../manager/pinned_album_ids_manager.dart';
import 'album_page.dart';
import 'local_cover.dart';

class AlbumCard extends ConsumerWidget {
  const AlbumCard({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinned =
        ref.watch(pinnedAlbumIDsManagerProvider).value?.contains(id) ?? false;

    return _AlbumCard(
      id: id,
      overlay: pinned
          ? Positioned(
              left: 0,
              bottom: 0,
              child: AudioCardVignette(
                iconData: Iconz.pinFilled,
                onTap: () => ref
                    .read(pinnedAlbumIDsManagerProvider.notifier)
                    .togglePinAlbum(id),
              ),
            )
          : null,
    );
  }
}

class _AlbumCard extends ConsumerWidget {
  const _AlbumCard({required this.id, this.overlay});

  final int id;
  final Widget? overlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AudioCard(
    bottom: AudioCardBottom(
      text: ref.watch(findAlbumNameManagerProvider(id)).value,
    ),
    image: LocalCover(
      dimension: audioCardDimension,
      albumId: id,
      fallback: CoverBackground(dimension: audioCardDimension),
    ),
    onTap: () => ref.read(routingManagerProvider.notifier).push(
      builder: (context) => AlbumPage(id: id),
      pageId: id.toString(),
    ),
    onPlay: () => ref.read(playAnywhereManagerProvider.notifier).play(
      PlayAnywhereParam(
        pageId: id.toString(),
        audioPageType: AudioPageType.album,
      ),
    ),
    overlay: overlay,
  );
}
