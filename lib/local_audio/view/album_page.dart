import 'package:animated_emoji/animated_emoji.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
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
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../local_audio_model.dart';
import 'artist_page.dart';
import 'local_cover.dart';

class AlbumPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const AlbumPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  late Future<List<Audio>?> _album;

  @override
  void initState() {
    super.initState();
    getAlbum();
  }

  void getAlbum() => _album = di<LocalAudioModel>().findAlbum(widget.id);

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LocalAudioModel m) {
      getAlbum();
      return m.audios.hashCode;
    });

    return FutureBuilder(
      future: _album,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            appBar: HeaderBar(adaptive: true),
            body: Center(
              child: Progress(),
            ),
          );
        }

        final album = snapshot.data!;

        return SliverAudioPage(
          pageId: widget.id,
          audioPageType: AudioPageType.album,
          audios: album,
          image: AlbumPageImage(audio: album.firstOrNull),
          noSearchResultIcons: const AnimatedEmoji(AnimatedEmojis.bubbles),
          noSearchResultMessage: Text(context.l10n.albumNotFound),
          pageTitle: album.firstWhereOrNull((e) => e.album != null)?.album,
          pageSubTitle: album.firstWhereOrNull((e) => e.artist != null)?.artist,
          onPageSubTitleTab: onArtistTap,
          onPageLabelTab: onArtistTap,
          controlPanel: AlbumPageControlButton(album: album, id: widget.id),
        );
      },
    );
  }

  void onArtistTap(String text) => di<RoutingManager>().push(
        builder: (_) => ArtistPage(pageId: text),
        pageId: text,
      );
}

class AlbumPageSideBarIcon extends StatefulWidget {
  const AlbumPageSideBarIcon({super.key, required this.albumId});

  final String albumId;

  @override
  State<AlbumPageSideBarIcon> createState() => _AlbumPageSideBarIconState();
}

class _AlbumPageSideBarIconState extends State<AlbumPageSideBarIcon> {
  late Future<String?> _future;

  @override
  void initState() {
    super.initState();
    _future = di<LocalAudioModel>().findCoverPath(widget.albumId);
  }

  @override
  Widget build(BuildContext context) {
    final fallBack = SideBarFallBackImage(
      child: Icon(
        Iconz.startPlayList,
        color: getAlphabetColor(widget.albumId),
      ),
    );

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        final path = snapshot.data;
        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: path == null
              ? fallBack
              : LocalCover(
                  albumId: widget.albumId,
                  path: path,
                  fallback: fallBack,
                  dimension: sideBarImageSize,
                ),
        );
      },
    );
  }
}

class AlbumPageImage extends StatelessWidget {
  const AlbumPageImage({
    super.key,
    required this.audio,
  });

  final Audio? audio;

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
        Align(
          alignment: Alignment.centerLeft,
          child: audio != null && audio!.canHaveLocalCover
              ? LocalCover(
                  albumId: audio!.albumId!,
                  path: audio!.path!,
                  dimension: kMaxAudioPageHeaderHeight,
                  fallback: const CoverBackground(
                    dimension: kMaxAudioPageHeaderHeight,
                  ),
                )
              : const CoverBackground(
                  dimension: kMaxAudioPageHeaderHeight,
                ),
        ),
      ],
    );
  }
}

class AlbumPageControlButton extends StatelessWidget with WatchItMixin {
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
    final pinnedAlbum =
        watchPropertyValue((LibraryModel m) => m.isFavoriteAlbum(id));
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: space(
        children: [
          IconButton(
            tooltip:
                pinnedAlbum ? context.l10n.unPinAlbum : context.l10n.pinAlbum,
            isSelected: pinnedAlbum,
            icon: Icon(
              pinnedAlbum ? Iconz.pinFilled : Iconz.pin,
            ),
            onPressed: () {
              if (pinnedAlbum) {
                libraryModel.removeFavoriteAlbum(
                  id,
                  onFail: () {
                    showSnackBar(
                      context: context,
                      content: Text(context.l10n.cantUnpinEmptyAlbum),
                    );
                  },
                );
              } else {
                libraryModel.addFavoriteAlbum(
                  id,
                  onFail: () {
                    showSnackBar(
                      context: context,
                      content: Text(context.l10n.cantPinEmptyAlbum),
                    );
                  },
                );
              }
            },
          ),
          AvatarPlayButton(audios: album, pageId: id),
          AudioTileOptionButton(
            audios: album,
            playlistId: id,
            allowRemove: false,
            selected: false,
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
