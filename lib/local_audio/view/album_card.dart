import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

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

class AlbumCard extends StatelessWidget with WatchItMixin {
  const AlbumCard({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final pinned = watchValue(
      (PinnedAlbumIDsManager m) => m.command,
    ).contains(id);

    return _AlbumCard(
      id: id,
      overlay: pinned
          ? Positioned(
              left: 0,
              bottom: 0,
              child: AudioCardVignette(
                iconData: Iconz.pinFilled,
                onTap: () => di<PinnedAlbumIDsManager>().command.run(id),
              ),
            )
          : null,
    );
  }
}

class _AlbumCard extends StatelessWidget with WatchItMixin {
  const _AlbumCard({required this.id, this.overlay});

  final int id;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) => AudioCard(
    bottom: AudioCardBottom(
      text: watchValue((FindAlbumNameManager m) => m.command, param1: id),
    ),
    image: LocalCover(
      dimension: audioCardDimension,
      albumId: id,
      fallback: CoverBackground(dimension: audioCardDimension),
    ),
    onTap: () => di<RoutingManager>().push(
      builder: (context) => AlbumPage(id: id),
      pageId: id.toString(),
    ),
    onPlay: () => di<PlayAnywhereManager>().command.run(
      PlayAnywhereParam(
        pageId: id.toString(),
        audioPageType: AudioPageType.album,
      ),
    ),
    overlay: overlay,
  );
}
