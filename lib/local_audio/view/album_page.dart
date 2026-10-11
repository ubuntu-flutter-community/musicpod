import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/audio_tile_option_button.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/cover_background.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/local_audio_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../dependencies.dart';
import '../../extensions/build_context_x.dart';
import '../manager/find_album_manager.dart';
import '../manager/find_album_name_manager.dart';
import '../manager/find_artist_of_album_manager.dart';
import 'artist_page.dart';
import 'local_cover.dart';
import 'pin_album_button.dart';

class AlbumPage extends ConsumerWidget {
  const AlbumPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(findAlbumManagerProvider(id)).when(
        error: (error, stack) => Scaffold(
          appBar: const HeaderBar(),
          body: Center(child: Text(error.toString())),
        ),
        loading: () => const Scaffold(
          appBar: HeaderBar(),
          body: Center(child: Progress()),
        ),
        data: (album) {
          if (album == null) {
            return Scaffold(
              appBar: const HeaderBar(),
              body: Center(child: Text(context.l10n.albumNotFound)),
            );
          }

          return LocalAudioPage(
            pageId: id.toString(),
            audioPageType: AudioPageType.album,
            audios: album,
            image: AlbumPageImage(audio: album.firstOrNull),
            noSearchResultMessage: Text(context.l10n.albumNotFound),
            pageTitle: album.firstWhereOrNull((e) => e.album != null)?.album,
            pageSubTitle: album
                .firstWhereOrNull((e) => e.artist != null)
                ?.artist,
            onPageSubTitleTab: onArtistTap,
            onPageLabelTab: onArtistTap,
            controlPanel: AlbumPageControlPanel(album: album, id: id),
            startNewPlaylistOnTap: true,
          );
        },
      );

  void onArtistTap(String text) => di<RoutingManager>().push(
    builder: (_) => ArtistPage(pageId: text),
    pageId: text,
  );
}

class AlbumPageSideBarName extends ConsumerWidget {
  const AlbumPageSideBarName({super.key, required this.albumId});

  final int albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(findAlbumNameManagerProvider(albumId)).value ?? '...',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

class AlbumPageSideBarArtist extends ConsumerWidget {
  const AlbumPageSideBarArtist({super.key, required this.albumId});

  final int albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(findArtistOfAlbumManagerProvider(albumId)).value ?? '...',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

class AlbumPageSideBarIcon extends ConsumerWidget {
  const AlbumPageSideBarIcon({super.key, required this.albumId});

  final int albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumName = ref.watch(findAlbumNameManagerProvider(albumId)).value;
    final alphabetColor = getAlphabetColor(albumName ?? 'a');

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: LocalCover(
        albumId: albumId,
        fallback: SideBarFallBackImage(
          color: alphabetColor,
          child: Icon(Iconz.startPlayList),
        ),
        dimension: sideBarImageSize,
      ),
    );
  }
}

class AlbumPageImage extends StatelessWidget {
  const AlbumPageImage({super.key, required this.audio});

  final Audio? audio;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: audio != null && audio!.canHaveLocalCover
        ? LocalCover(
            albumId: audio!.albumDbId!,
            dimension: kMaxAudioPageHeaderHeight,
            fallback: const CoverBackground(
              dimension: kMaxAudioPageHeaderHeight,
            ),
          )
        : const CoverBackground(dimension: kMaxAudioPageHeaderHeight),
  );
}

class AlbumPageControlPanel extends StatelessWidget {
  const AlbumPageControlPanel({
    super.key,
    required this.id,
    required this.album,
  });

  final int id;
  final List<Audio> album;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: space(
      children: [
        PinAlbumButton(albumId: id),
        AvatarPlayButton(
          pageId: id.toString(),
          audioPageType: AudioPageType.album,
        ),
        AudioTileOptionButton(
          audios: album,
          playlistId: id.toString(),
          allowRemove: false,
          searchTerm:
              '${album.firstOrNull?.artist} - ${album.firstOrNull?.album}',
          title: Text('${album.firstOrNull?.artist}'),
          subTitle: Text('${album.firstOrNull?.album}'),
        ),
      ],
    ),
  );
}
