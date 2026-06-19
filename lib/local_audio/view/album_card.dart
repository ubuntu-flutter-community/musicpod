import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/routing_manager.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/audio_card_vignette.dart';
import '../../common/view/cover_background.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/command_x.dart';
import '../../player/player_manager.dart';
import '../find_album_manager.dart';
import '../find_album_name_manager.dart';
import '../pinned_album_i_ds_manager.dart';
import 'album_page.dart';
import 'local_cover.dart';

class AlbumCard extends StatelessWidget with WatchItMixin {
  const AlbumCard({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final pinned = watchValue(
      (PinnedAlbumIDsManager m) => m.command.select((e) => e.contains(id)),
    );

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
    onPlay: () async => di<PlayerManager>().startPlaylist(
      audios:
          await di<FindAlbumManager>(param1: id).command.runRestrictedAsync() ??
          [],
      listName: id.toString(),
    ),
    overlay: overlay,
  );
}
