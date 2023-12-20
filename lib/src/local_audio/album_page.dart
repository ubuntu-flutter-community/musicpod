import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../data.dart';
import '../l10n/l10n.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({
    super.key,
    required this.id,
    required this.isPinnedAlbum,
    required this.removePinnedAlbum,
    required this.album,
    required this.addPinnedAlbum,
    this.onTextTap,
  });

  static Widget createIcon(
    BuildContext context,
    Uint8List? picture,
  ) {
    Widget? albumArt;
    if (picture != null) {
      albumArt = SizedBox(
        width: sideBarImageSize,
        height: sideBarImageSize,
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
  final bool Function(String name) isPinnedAlbum;
  final void Function(String name) removePinnedAlbum;
  final Set<Audio>? album;
  final void Function(String name, Set<Audio> audios) addPinnedAlbum;
  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  @override
  Widget build(BuildContext context) {
    final image = album?.firstOrNull?.pictureData != null
        ? Image.memory(
            album!.firstOrNull!.pictureData!,
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          )
        : null;
    return AudioPage(
      showAudioPageHeader: image != null,
      showAlbum: false,
      onTextTap: onTextTap,
      audioPageType: AudioPageType.album,
      headerLabel: context.l10n.album,
      headerSubtile: album?.firstOrNull?.artist,
      image: image,
      controlPanelButton: Row(
        children: [
          if (isPinnedAlbum(id))
            IconButton(
              icon: Icon(
                Iconz().pinFilled,
                color: context.t.colorScheme.primary,
              ),
              onPressed: () => removePinnedAlbum(
                id,
              ),
            )
          else
            IconButton(
              icon: Icon(
                Iconz().pin,
              ),
              onPressed: album == null
                  ? null
                  : () => addPinnedAlbum(
                        id,
                        album!,
                      ),
            ),
          StreamProviderRow(
            spacing: const EdgeInsets.only(right: 10),
            text:
                '${album?.firstOrNull?.artist} - ${album?.firstOrNull?.album}',
          ),
        ],
      ),
      audios: album,
      pageId: id,
      headerTitle: album?.firstOrNull?.album,
    );
  }
}
