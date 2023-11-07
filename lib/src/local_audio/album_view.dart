import 'package:flutter/material.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../utils.dart';
import '../data/audio.dart';
import '../l10n/l10n.dart';
import 'album_page.dart';
import 'shop_recommendations.dart';

class AlbumsView extends StatelessWidget {
  const AlbumsView({
    super.key,
    required this.albums,
    required this.showWindowControls,
    this.onTextTap,
    required this.startPlaylist,
    required this.isPinnedAlbum,
    required this.removePinnedAlbum,
    required this.addPinnedAlbum,
    required this.findAlbum,
  });

  final Set<Audio>? albums;
  final bool showWindowControls;
  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  final Future<void> Function(Set<Audio>, String) startPlaylist;
  final bool Function(String) isPinnedAlbum;
  final void Function(String) removePinnedAlbum;
  final void Function(String, Set<Audio>) addPinnedAlbum;
  final Set<Audio>? Function(Audio, [AudioFilter]) findAlbum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (albums == null) {
      return const Center(
        child: Progress(),
      );
    }

    if (albums!.isEmpty) {
      return NoSearchResultPage(
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.noLocalTitlesFound),
            const ShopRecommendations(),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: gridPadding,
      itemCount: albums!.length,
      gridDelegate: imageGridDelegate,
      itemBuilder: (context, index) {
        final audio = albums!.elementAt(index);
        String? id = generateAlbumId(audio);
        final albumAudios = findAlbum(audio);

        final image = audio.pictureData == null
            ? Center(
                child: Icon(
                  Iconz().musicNote,
                  size: 140,
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
            child:
                AudioCardBottom(text: audio.album == null ? '' : audio.album!),
          ),
          image: image,
          onTap: id == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return AlbumPage(
                          onTextTap: ({required audioType, required text}) {
                            onTextTap?.call(text: text, audioType: audioType);
                            Navigator.of(context).maybePop();
                          },
                          id: id,
                          isPinnedAlbum: isPinnedAlbum,
                          removePinnedAlbum: removePinnedAlbum,
                          album: albumAudios,
                          addPinnedAlbum: addPinnedAlbum,
                        );
                      },
                    ),
                  ),
          onPlay: albumAudios == null || albumAudios.isEmpty || id == null
              ? null
              : () => startPlaylist(albumAudios, id),
        );
      },
    );
  }
}
