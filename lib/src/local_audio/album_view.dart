import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../library.dart';
import '../../player.dart';
import '../../utils.dart';
import '../data/audio.dart';
import '../l10n/l10n.dart';
import 'album_page.dart';
import 'local_audio_model.dart';

class AlbumsView extends ConsumerWidget {
  const AlbumsView({
    super.key,
    required this.albums,
    this.noResultMessage,
    this.noResultIcon,
  });

  final Set<Audio>? albums;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final libraryModel = ref.read(libraryModelProvider);
    final playerModel = ref.read(playerModelProvider);
    final model = ref.read(localAudioModelProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: GridView.builder(
        padding: gridPadding,
        itemCount: albums!.length,
        gridDelegate: audioCardGridDelegate,
        itemBuilder: (context, index) {
          final audio = albums!.elementAt(index);
          String? id = generateAlbumId(audio);
          final albumAudios = model.findAlbum(audio);

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
                  height: kAudioCardDimension,
                  filterQuality: FilterQuality.medium,
                );

          return AudioCard(
            bottom: Align(
              alignment: Alignment.bottomCenter,
              child: AudioCardBottom(
                text: audio.album?.isNotEmpty == false
                    ? context.l10n.unknown
                    : audio.album ?? '',
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
                : () => playerModel.startPlaylist(
                      audios: albumAudios,
                      listName: id,
                    ),
          );
        },
      ),
    );
  }
}
