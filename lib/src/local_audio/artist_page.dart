import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../data.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../utils.dart';
import '../l10n/l10n.dart';

class ArtistPage extends StatelessWidget {
  const ArtistPage({
    super.key,
    required this.images,
    required this.artistAudios,
  });

  final Set<Uint8List>? images;
  final Set<Audio>? artistAudios;

  @override
  Widget build(BuildContext context) {
    final model = context.read<LocalAudioModel>();
    final libraryModel = context.read<LibraryModel>();

    return AudioPage(
      showArtist: false,
      onAlbumTap: ({required audioType, required text}) {
        final audios = model.findAlbum(Audio(album: text));
        if (audios?.firstOrNull == null) return;
        final id = generateAlbumId(audios!.first);
        if (id == null) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return AlbumPage(
                isPinnedAlbum: libraryModel.isPinnedAlbum,
                removePinnedAlbum: libraryModel.removePinnedAlbum,
                addPinnedAlbum: libraryModel.addPinnedAlbum,
                id: id,
                album: audios,
              );
            },
          ),
        );
      },
      audioPageType: AudioPageType.artist,
      headerLabel: context.l10n.artist,
      headerTitle: artistAudios?.firstOrNull?.artist,
      showAudioPageHeader: images?.isNotEmpty == true,
      image: ArtistImage(images: images),
      imageRadius: BorderRadius.circular(10000),
      headerSubtile: artistAudios?.firstOrNull?.genre,
      audios: artistAudios,
      pageId: artistAudios?.firstOrNull?.artist ?? artistAudios.toString(),
      controlPanelButton: Row(
        children: [
          StreamProviderRow(
            spacing: const EdgeInsets.only(right: 10),
            text: artistAudios?.firstOrNull?.artist,
          ),
        ],
      ),
    );
  }
}
