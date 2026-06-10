import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/routing_manager.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/audio_card_vignette.dart';
import '../../common/view/cover_background.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/command_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../player/player_manager.dart';
import '../local_audio_manager.dart';
import 'album_page.dart';
import 'local_cover.dart';

class AlbumCard extends StatelessWidget with WatchItMixin {
  const AlbumCard({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final pinned = watchValue(
      (LocalAudioManager m) =>
          m.togglePinnedAlbumCommand.select((e) => e.contains(id)),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        _AlbumCard(id: id),
        if (pinned)
          Positioned(
            left: isMobile ? 6 : 5,
            bottom: kAudioCardBottomHeight + (isMobile ? 25 : 13),
            child: AudioCardVignette(
              iconData: Iconz.pinFilled,
              onTap: () =>
                  di<LocalAudioManager>().togglePinnedAlbumCommand.run(id),
            ),
          ),
      ],
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) => AudioCard(
    bottom: AudioCardBottom(
      text: di<LocalAudioManager>().findAlbumName(id) ?? '',
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
          await di<LocalAudioManager>()
              .findAlbumCommand(id)
              .runRestrictedAsync() ??
          [],
      listName: id.toString(),
    ),
  );
}
