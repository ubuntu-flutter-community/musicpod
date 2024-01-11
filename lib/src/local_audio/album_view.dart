import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';

import '../../build_context_x.dart';
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
    required this.startPlaylist,
    required this.isPinnedAlbum,
    required this.removePinnedAlbum,
    required this.addPinnedAlbum,
    required this.findAlbum,
  });

  final Set<Audio>? albums;

  final Future<void> Function({
    required Set<Audio> audios,
    required String listName,
    int? index,
  }) startPlaylist;
  final bool Function(String) isPinnedAlbum;
  final void Function(String) removePinnedAlbum;
  final void Function(String, Set<Audio>) addPinnedAlbum;
  final Set<Audio>? Function(Audio, [AudioFilter]) findAlbum;

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
        icons: const AnimatedEmoji(AnimatedEmojis.eyes),
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.noLocalTitlesFound),
            const ShopRecommendations(),
          ],
        ),
      );
    }

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
          final albumAudios = findAlbum(audio);

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
                : () => startPlaylist(audios: albumAudios, listName: id),
          );
        },
      ),
    );
  }
}
