import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../library.dart';
import '../../player.dart';
import '../../utils.dart';
import '../data/audio.dart';
import '../l10n/l10n.dart';
import 'album_page.dart';
import 'local_audio_service.dart';

class AlbumsView extends StatelessWidget {
  const AlbumsView({
    super.key,
    required this.albums,
    this.noResultMessage,
    this.noResultIcon,
  });

  final Set<Audio>? albums;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    if (albums == null) {
      return const Center(
        child: Progress(),
      );
    }

    if (albums!.isEmpty) {
      return NoSearchResultPage(
        icons: noResultIcon,
        message: noResultMessage,
      );
    }

    final libraryModel = context.read<LibraryModel>();
    final playerService = getService<PlayerService>();
    final service = getService<LocalAudioService>();

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: GridView.builder(
        shrinkWrap: true,
        padding: gridPadding,
        itemCount: albums!.length,
        gridDelegate: imageGridDelegate,
        itemBuilder: (context, index) {
          final audio = albums!.elementAt(index);
          String? id = generateAlbumId(audio);
          final albumAudios = service.findAlbum(audio);

          final image = audio.pictureData == null
              ? Center(
                  child: Icon(
                    Iconz().musicNote,
                    size: 70,
                    color: theme.hintColor,
                  ),
                )
              : Image.memory(
                  audio.pictureData!,
                  fit: BoxFit.cover,
                  height: kSmallCardHeight,
                  filterQuality: FilterQuality.medium,
                );

          return AudioCard(
            bottom: Align(
              alignment: Alignment.bottomCenter,
              child: AudioCardBottom(
                text: audio.album?.isNotEmpty == false
                    ? context.l10n.unknown
                    : audio.album!,
              ),
            ),
            image: image,
            onTap: id == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return AlbumPage(
                            id: id,
                            isPinnedAlbum: libraryModel.isPinnedAlbum,
                            removePinnedAlbum: libraryModel.removePinnedAlbum,
                            album: albumAudios,
                            addPinnedAlbum: libraryModel.addPinnedAlbum,
                          );
                        },
                      ),
                    ),
            onPlay: albumAudios == null || albumAudios.isEmpty || id == null
                ? null
                : () => playerService.startPlaylist(
                      audios: albumAudios,
                      listName: id,
                    ),
          );
        },
      ),
    );
  }
}
