import 'package:flutter/material.dart';

import '../../../common.dart';
import '../../../constants.dart';
import '../../../get.dart';
import '../../../player.dart';
import '../../data/audio.dart';
import '../../l10n/l10n.dart';
import '../local_audio_model.dart';
import 'album_page.dart';

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

    final playerModel = getIt<PlayerModel>();
    final model = getIt<LocalAudioModel>();

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: GridView.builder(
        padding: gridPadding,
        itemCount: albums!.length,
        gridDelegate: audioCardGridDelegate,
        itemBuilder: (context, index) {
          final audio = albums!.elementAt(index);
          String? id = audio.albumId;
          final albumAudios = model.findAlbum(audio);

          final image = audio.pictureData == null
              ? null
              : Image.memory(
                  audio.pictureData!,
                  fit: BoxFit.fitHeight,
                  height: kAudioCardDimension,
                  filterQuality: FilterQuality.medium,
                );

          final fallback = Image.asset(
            'assets/images/media-optical.png',
            height: kAudioCardDimension,
            width: kAudioCardDimension,
          );

          return AudioCard(
            bottom: AudioCardBottom(
              text: audio.album?.isNotEmpty == false
                  ? context.l10n.unknown
                  : audio.album ?? '',
            ),
            image: image ?? fallback,
            background: fallback,
            onTap: id == null || albumAudios == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return AlbumPage(
                            id: id,
                            album: albumAudios,
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
