import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/audio_tile_option_button.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/cover_background.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/sliver_audio_page.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../local_audio_manager.dart';
import 'artist_page.dart';
import 'local_cover.dart';
import 'pin_album_button.dart';

class AlbumPage extends StatelessWidget with WatchItMixin {
  const AlbumPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild(
      (context) => di<LocalAudioManager>().findAlbumCommand(id).run(),
    );

    return watchValue(
      (LocalAudioManager m) => m.findAlbumCommand(id).results,
    ).toWidget(
      onError: (error, lastResult, param) => Scaffold(
        appBar: const HeaderBar(adaptive: true),
        body: Center(child: Text(error.toString())),
      ),
      whileRunning: (lastResult, param) => const Scaffold(
        appBar: HeaderBar(adaptive: true),
        body: Center(child: Progress()),
      ),
      onData: (album, param) {
        if (album == null) {
          return Scaffold(
            appBar: const HeaderBar(adaptive: true),
            body: Center(child: Text(context.l10n.albumNotFound)),
          );
        }

        return SliverAudioPage(
          pageId: id.toString(),
          audioPageType: AudioPageType.album,
          audios: album,
          image: AlbumPageImage(audio: album.firstOrNull),
          noSearchResultMessage: Text(context.l10n.albumNotFound),
          pageTitle: album.firstWhereOrNull((e) => e.album != null)?.album,
          pageSubTitle: album.firstWhereOrNull((e) => e.artist != null)?.artist,
          onPageSubTitleTab: onArtistTap,
          onPageLabelTab: onArtistTap,
          controlPanel: AlbumPageControlPanel(album: album, id: id),
        );
      },
    );
  }

  void onArtistTap(String text) => di<RoutingManager>().push(
    builder: (_) => ArtistPage(pageId: text),
    pageId: text,
  );
}

class AlbumPageSideBarIcon extends StatelessWidget with WatchItMixin {
  const AlbumPageSideBarIcon({super.key, required this.albumId});

  final int albumId;

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild(
      (context) => di<LocalAudioManager>().findAlbumCommand(albumId).run(),
    );
    final albumName =
        di<LocalAudioManager>().findAlbumName(albumId) ?? albumId.toString();
    final alphabetColor = getAlphabetColor(albumName);

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child:
          watchValue(
            (LocalAudioManager m) => m.findAlbumCommand(albumId).results,
          ).toWidget(
            onError: (error, lastResult, param) {
              return SideBarFallBackImage(
                color: alphabetColor,
                child: Icon(Iconz.startPlayList),
              );
            },
            whileRunning: (lastResult, param) => Shimmer.fromColors(
              child: SideBarFallBackImage(
                color: alphabetColor,
                child: const SizedBox.shrink(),
              ),
              baseColor: alphabetColor,
              highlightColor: alphabetColor.withValues(alpha: 0.5),
            ),
            onData: (album, param) {
              final path = album
                  ?.firstWhereOrNull((e) => e.albumDbId == albumId)
                  ?.path;
              return path == null
                  ? SideBarFallBackImage(
                      color: alphabetColor,
                      child: Icon(Iconz.startPlayList),
                    )
                  : LocalCover(
                      albumId: albumId,
                      path: path,
                      fallback: SideBarFallBackImage(
                        color: alphabetColor,
                        child: Icon(Iconz.startPlayList),
                      ),
                      dimension: sideBarImageSize,
                    );
            },
          ),
    );
  }
}

class AlbumPageImage extends StatelessWidget with WatchItMixin {
  const AlbumPageImage({super.key, required this.audio});

  final Audio? audio;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: audio != null && audio!.canHaveLocalCover
          ? watchValue(
              (LocalAudioManager m) =>
                  m.findAlbumCommand(audio!.albumDbId!).results,
            ).toWidget(
              whileRunning: (lastResult, param) => Shimmer.fromColors(
                child: const SizedBox.square(
                  dimension: kMaxAudioPageHeaderHeight,
                ),
                baseColor: getAlphabetColor(audio!.album ?? ''),
                highlightColor: getAlphabetColor(
                  audio!.album ?? '',
                ).withValues(alpha: 0.5),
              ),
              onError: (error, lastResult, param) =>
                  const CoverBackground(dimension: kMaxAudioPageHeaderHeight),
              onData: (album, param) => LocalCover(
                albumId: audio!.albumDbId!,
                path: audio!.path!,
                dimension: kMaxAudioPageHeaderHeight,
                fallback: const CoverBackground(
                  dimension: kMaxAudioPageHeaderHeight,
                ),
              ),
            )
          : const CoverBackground(dimension: kMaxAudioPageHeaderHeight),
    );
  }
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: space(
        children: [
          PinAlbumButton(albumId: id),
          AvatarPlayButton(audios: album, pageId: id.toString()),
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
}
