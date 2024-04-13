import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../data.dart';
import '../../get.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../common/explore_online_popup.dart';
import '../l10n/l10n.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({
    super.key,
    required this.id,
    required this.album,
  });

  static Widget createIcon(
    BuildContext context,
    Uint8List? picture,
  ) {
    Widget? albumArt;
    if (picture != null) {
      albumArt = SizedBox.square(
        dimension: sideBarImageSize,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.memory(
            picture,
            height: sideBarImageSize,
            fit: BoxFit.fitHeight,
            filterQuality: FilterQuality.medium,
          ),
        ),
      );
    }
    return albumArt ??
        Icon(
          Iconz().startPlayList,
        );
  }

  final String id;
  final Set<Audio> album;

  @override
  Widget build(BuildContext context) {
    final model = getIt<LocalAudioModel>();
    final pictureData =
        album.firstWhereOrNull((e) => e.pictureData != null)?.pictureData;

    void onArtistTap(text) {
      final artistName = album.firstOrNull?.artist;
      if (artistName == null) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            final artistAudios = model.findArtist(album.first);
            final images = model.findImages(artistAudios ?? {});

            return ArtistPage(
              images: images,
              artistAudios: artistAudios,
            );
          },
        ),
      );
    }

    return AudioPage(
      showAlbum: false,
      onArtistTap: onArtistTap,
      onSubTitleTab: onArtistTap,
      audioPageType: AudioPageType.album,
      headerLabel: context.l10n.album,
      headerSubtile: album.firstOrNull?.artist,
      image: AlbumPageImage(pictureData: pictureData),
      controlPanelButton: _AlbumPageControlButton(album: album, id: id),
      audios: album,
      pageId: id,
      headerTitle: album.firstOrNull?.album,
    );
  }
}

class AlbumPageImage extends StatelessWidget {
  const AlbumPageImage({
    super.key,
    required this.pictureData,
  });

  final Uint8List? pictureData;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.t.cardColor,
            image: const DecorationImage(
              image: AssetImage('assets/images/media-optical.png'),
            ),
          ),
        ),
        if (pictureData != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Image.memory(
              pictureData!,
              fit: BoxFit.fitHeight,
              filterQuality: FilterQuality.medium,
            ),
          ),
      ],
    );
  }
}

class _AlbumPageControlButton extends StatelessWidget {
  const _AlbumPageControlButton({required this.id, required this.album});

  final String id;
  final Set<Audio> album;

  @override
  Widget build(BuildContext context) {
    final libraryModel = getIt<LibraryModel>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: IconButton(
            tooltip: context.l10n.pinAlbum,
            isSelected: libraryModel.isPinnedAlbum(id),
            icon: Icon(
              libraryModel.isPinnedAlbum(id) ? Iconz().pinFilled : Iconz().pin,
            ),
            onPressed: () {
              if (libraryModel.isPinnedAlbum(id)) {
                libraryModel.removePinnedAlbum(id);
              } else {
                libraryModel.addPinnedAlbum(id, album);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: ExploreOnlinePopup(
            text: '${album.firstOrNull?.artist} - ${album.firstOrNull?.album}',
          ),
        ),
      ],
    );
  }
}
