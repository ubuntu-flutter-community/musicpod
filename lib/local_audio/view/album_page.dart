import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/explore_online_popup.dart';
import '../../common/view/icons.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/sliver_audio_page.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../local_audio_model.dart';
import 'artist_page.dart';
import 'local_cover.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({
    super.key,
    required this.id,
    required this.album,
  });

  final String id;
  final Set<Audio> album;

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();

    void onArtistTap(text) {
      final artistName = album.firstOrNull?.artist;
      if (artistName == null) return;

      di<LibraryModel>().push(
        builder: (_) {
          final artistAudios = model.findTitlesOfArtist(artistName);
          final images = model.findImages(artistAudios ?? {});

          return ArtistPage(
            images: images,
            artistAudios: artistAudios,
          );
        },
        pageId: artistName,
      );
    }

    return SliverAudioPage(
      pageId: id,
      audioPageType: AudioPageType.album,
      audios: album,
      image: album.isEmpty ? null : AlbumPageImage(audio: album.first),
      pageTitle: album.firstWhereOrNull((e) => e.album != null)?.album,
      pageSubTitle: album.firstWhereOrNull((e) => e.artist != null)?.artist,
      onPageLabelTab: onArtistTap,
      onPageSubTitleTab: onArtistTap,
      controlPanel: AlbumPageControlButton(album: album, id: id),
    );
  }
}

// ignore: unused_element
Future<Color?> _loadColor({Audio? audio}) async {
  if (audio?.pictureData == null &&
      audio?.imageUrl == null &&
      audio?.albumArtUrl == null) {
    return null;
  }

  ImageProvider? image;
  if (audio?.pictureData != null) {
    image = MemoryImage(
      audio!.pictureData!,
    );
  } else {
    image = NetworkImage(
      audio!.imageUrl ?? audio.albumArtUrl!,
    );
  }
  final generator = await PaletteGenerator.fromImageProvider(image);
  return generator.dominantColor?.color;
}

class AlbumPageSideBarIcon extends StatelessWidget {
  const AlbumPageSideBarIcon({super.key, this.picture, this.album});

  final Uint8List? picture;
  final String? album;

  @override
  Widget build(BuildContext context) {
    if (picture == null) {
      return SideBarFallBackImage(
        child: Icon(
          Iconz().startPlayList,
          color: getAlphabetColor(album ?? 'c'),
        ),
      );
    }

    return SizedBox.square(
      dimension: sideBarImageSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.memory(
          picture!,
          height: sideBarImageSize,
          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

class AlbumPageImage extends StatelessWidget {
  const AlbumPageImage({
    super.key,
    required this.audio,
  });

  final Audio audio;

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
        Align(
          alignment: Alignment.centerLeft,
          child: LocalCover(
            audio: audio,
            dimension: kMaxAudioPageHeaderHeight,
          ),
        ),
      ],
    );
  }
}

class AlbumPageControlButton extends StatelessWidget {
  const AlbumPageControlButton({
    super.key,
    required this.id,
    required this.album,
  });

  final String id;
  final Set<Audio> album;

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final pinnedAlbum = libraryModel.isPinnedAlbum(id);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: context.l10n.pinAlbum,
          isSelected: libraryModel.isPinnedAlbum(id),
          icon: Icon(
            pinnedAlbum ? Iconz().pinFilled : Iconz().pin,
            color: pinnedAlbum ? context.t.colorScheme.primary : null,
          ),
          onPressed: () {
            if (libraryModel.isPinnedAlbum(id)) {
              libraryModel.removePinnedAlbum(id);
            } else {
              libraryModel.addPinnedAlbum(id, album);
            }
          },
        ),
        AvatarPlayButton(audios: album, pageId: id),
        ExploreOnlinePopup(
          text: '${album.firstOrNull?.artist} - ${album.firstOrNull?.album}',
        ),
      ],
    );
  }
}
