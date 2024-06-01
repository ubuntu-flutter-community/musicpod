import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../common.dart';
import '../../../constants.dart';
import '../../../player.dart';
import '../../data/audio.dart';
import '../local_audio_model.dart';
import 'album_page.dart';

class AlbumsView extends StatelessWidget {
  const AlbumsView({
    super.key,
    required this.albums,
    this.noResultMessage,
    this.noResultIcon,
    required this.sliver,
  });

  final Set<Audio>? albums;
  final Widget? noResultMessage, noResultIcon;
  final bool sliver;

  @override
  Widget build(BuildContext context) {
    if (sliver) {
      if (albums == null) {
        return const SliverToBoxAdapter(
          child: Center(
            child: Progress(),
          ),
        );
      }

      if (albums!.isEmpty) {
        return SliverToBoxAdapter(
          child: NoSearchResultPage(
            icons: noResultIcon,
            message: noResultMessage,
          ),
        );
      }

      return SliverPadding(
        padding: gridPadding,
        sliver: SliverGrid.builder(
          itemCount: albums!.length,
          gridDelegate: audioCardGridDelegate,
          itemBuilder: itemBuilder,
        ),
      );
    } else {
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

      return Padding(
        padding: const EdgeInsets.only(top: 15),
        child: GridView.builder(
          padding: gridPadding,
          itemCount: albums!.length,
          gridDelegate: audioCardGridDelegate,
          itemBuilder: itemBuilder,
        ),
      );
    }
  }

  Widget itemBuilder(context, index) {
    final playerModel = di<PlayerModel>();
    final model = di<LocalAudioModel>();
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
  }
}
