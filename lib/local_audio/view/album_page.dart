import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/cover_background.dart';
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
  final List<Audio> album;

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();

    void onArtistTap(text) {
      final artistName = album.firstOrNull?.artist;
      if (artistName == null) return;

      model.init().then(
            (_) => di<LibraryModel>().push(
              builder: (_) {
                final artistAudios = model.findTitlesOfArtist(artistName);
                return ArtistPage(
                  artistAudios: artistAudios,
                );
              },
              pageId: artistName,
            ),
          );
    }

    return SliverAudioPage(
      pageId: id,
      audioPageType: AudioPageType.album,
      audios: album,
      image: album.isEmpty ? null : AlbumPageImage(audio: album.first),
      pageTitle: album.firstWhereOrNull((e) => e.album != null)?.album,
      pageSubTitle: album.firstWhereOrNull((e) => e.artist != null)?.artist,
      onPageSubTitleTab: onArtistTap,
      controlPanel: AlbumPageControlButton(album: album, id: id),
    );
  }
}

class AlbumPageSideBarIcon extends StatelessWidget {
  const AlbumPageSideBarIcon({super.key, required this.audio});

  final Audio? audio;

  @override
  Widget build(BuildContext context) {
    final fallBack = SideBarFallBackImage(
      child: Icon(
        Iconz.startPlayList,
        color: getAlphabetColor(audio?.album ?? 'c'),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: audio?.hasPathAndId == false
          ? fallBack
          : LocalCover(
              albumId: audio!.albumId!,
              path: audio!.path!,
              fallback: fallBack,
              dimension: sideBarImageSize,
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
            color: context.theme.cardColor,
            image: const DecorationImage(
              image: AssetImage('assets/images/media-optical.png'),
            ),
          ),
        ),
        if (audio.hasPathAndId == true)
          Align(
            alignment: Alignment.centerLeft,
            child: LocalCover(
              albumId: audio.albumId!,
              path: audio.path!,
              dimension: kMaxAudioPageHeaderHeight,
              fallback: const CoverBackground(
                dimension: kMaxAudioPageHeaderHeight,
              ),
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
  final List<Audio> album;

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final pinnedAlbum = libraryModel.isPinnedAlbum(id);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: space(
        children: [
          IconButton(
            tooltip:
                pinnedAlbum ? context.l10n.unPinAlbum : context.l10n.pinAlbum,
            isSelected: libraryModel.isPinnedAlbum(id),
            icon: Icon(
              pinnedAlbum ? Iconz.pinFilled : Iconz.pin,
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
      ),
    );
  }
}
