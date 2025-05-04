import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

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
import '../local_audio_model.dart';
import 'album_page.dart';
import 'local_cover.dart';

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
    final model = di<LocalAudioModel>();
    final cachedCoverPath = model.getCachedCoverPath(widget.id);
    _pathFuture = cachedCoverPath != null
        ? Future.value(cachedCoverPath)
        : model.findCoverPath(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();
    final cachedCoverPath = model.getCachedCoverPath(widget.id);
    if (cachedCoverPath != null) {
      return _AlbumCard(
        id: widget.id,
        path: cachedCoverPath,
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        FutureBuilder(
          future: _pathFuture,
          builder: (context, snapshot) {
            final path = snapshot.data;
            return _AlbumCard(path: path, id: widget.id);
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

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.path,
    required this.id,
  });

  final String id;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return AudioCard(
      bottom: AudioCardBottom(text: id.albumOfId),
      image: AnimatedOpacity(
        opacity: path == null ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        child: path != null
            ? LocalCover(
                dimension: audioCardDimension,
                albumId: id,
                path: path!,
                fallback: const CoverBackground(),
              )
            : null,
      ),
      background: const CoverBackground(),
      onTap: () => di<RoutingManager>().push(
        builder: (context) => AlbumPage(id: id),
        pageId: id,
      ),
      onPlay: () async => di<PlayerModel>().startPlaylist(
        audios: await di<LocalAudioModel>().findAlbum(id) ?? [],
        listName: id,
      ),
    );
  }
}
