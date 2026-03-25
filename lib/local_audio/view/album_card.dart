import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable_generator/utils.dart';

import '../../app/view/routing_manager.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/audio_card_vignette.dart';
import '../../common/view/cover_background.dart';
import '../../common/view/icons.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/string_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../local_audio_manager.dart';
import 'album_page.dart';
import 'local_cover.dart';

class AlbumCard extends StatelessWidget with WatchItMixin {
  const AlbumCard({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild(
      (context) => di<LocalAudioManager>().findAlbumCommand(id).run(),
    );

    final pinned = watchPropertyValue(
      (LibraryModel m) => m.isFavoriteAlbum(id),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        watchValue(
          (LocalAudioManager m) => m.findAlbumCommand(id).results,
        ).toWidget(
          onError: (error, lastResult, param) => _AlbumCard(id: id, path: null),
          whileRunning: (lastResult, param) => _AlbumCard(id: id, path: null),
          onData: (album, param) {
            final path = album?.firstWhereOrNull((e) => e.albumId == id)?.path;
            return _AlbumCard(id: id, path: path);
          },
        ),
        if (pinned)
          Positioned(
            left: isMobile ? 6 : 5,
            bottom: kAudioCardBottomHeight + (isMobile ? 25 : 13),
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

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.path, required this.id});

  final String id;
  final String? path;

  @override
  Widget build(BuildContext context) => AudioCard(
    bottom: AudioCardBottom(text: id.albumOfId),
    image: LocalCover(
      dimension: audioCardDimension,
      albumId: id,
      path: path,
      fallback: CoverBackground(dimension: audioCardDimension),
    ),
    onTap: () => di<RoutingManager>().push(
      builder: (context) => AlbumPage(id: id),
      pageId: id,
    ),
    onPlay: () async => di<PlayerModel>().startPlaylist(
      audios:
          await di<LocalAudioManager>().findAlbumCommand(id).runAsync() ?? [],
      listName: id,
    ),
  );
}
