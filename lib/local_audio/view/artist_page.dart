import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/audio_tile_option_button.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/genre_bar.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/like_all_icon_button.dart';
import '../../common/view/progress.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_local_audio_tile_list.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../search/manager/search_manager.dart';
import '../../search/data/search_type.dart';
import '../manager/album_ids_of_artist_manager.dart';
import '../manager/find_titles_of_artist_manager.dart';
import '../manager/local_audio_manager.dart';
import 'album_page.dart';
import 'album_view.dart';
import 'artist_image.dart';
import 'genre_page.dart';

class ArtistPage extends StatelessWidget {
  const ArtistPage({super.key, required this.pageId});

  final String pageId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: HeaderBar(
      title: Text(pageId),
      actions: [
        Padding(
          padding: appBarSingleActionSpacing,
          child: SearchButton(
            onPressed: () {
              di<RoutingManager>().push(pageId: PageIDs.searchPage);
              final searchManager = di<SearchManager>();
              searchManager
                ..setAudioType(AudioType.local)
                ..setSearchType(SearchType.localArtist)
                ..search();
            },
          ),
        ),
      ],
    ),
    body: _ArtistPageBody(pageId: pageId),
  );
}

class _ArtistPageBody extends StatelessWidget with WatchItMixin {
  const _ArtistPageBody({required this.pageId});

  final String pageId;

  @override
  Widget build(BuildContext context) {
    final useGridView = watchValue(
      (FindTitlesOfArtistManager m) => m.useArtistGridView,
      param1: pageId,
    );

    final results = watchValue(
      (FindTitlesOfArtistManager m) => m.command.results,
      param1: pageId,
    );

    if (results.isRunning) {
      return const Center(child: Progress());
    }

    if (results.hasError) {
      return Center(child: Text(results.error.toString()));
    }

    final artistAudios = results.data ?? [];

    return AdaptiveMultiLayoutBody(
      header: AudioPageHeader(
        imageRadius: BorderRadius.circular(10000),
        title: pageId,
        image: ArtistImage(
          artist: pageId,
          dimension: kMaxAudioPageHeaderHeight,
        ),
        subTitleWidget: GenreBar(audios: artistAudios),
        label: context.l10n.artist,
        onLabelTab: (text) => onAlbumTap(text: text, context: context),
        onSubTitleTab: (text) => di<RoutingManager>().push(
          builder: (context) => GenrePage(genre: text),
          pageId: text,
        ),
      ),
      controlPanel: _ArtistPageControlPanel(
        pageId: pageId,
        audios: artistAudios,
      ),
      sliverBody: (constraints) => useGridView
          ? _AlbumsOfArtistGridView(artist: pageId)
          : SliverLocalAudioTileList(
              audios: artistAudios,
              pageId: pageId,
              audioPageType: LocalAudioPageType.artist,
              onSubTitleTab: (text) => onAlbumTap(text: text, context: context),
              constraints: constraints,
              startNewPlaylistOnTap: true,
            ),
    );
  }

  Future<void> onAlbumTap({
    required String text,
    required BuildContext context,
  }) async {
    final id = await di<LocalAudioManager>().findAlbumId(
      artist: pageId,
      album: text,
    );

    if (id == null) {
      context.toast(Text(context.l10n.nothingFound));
      return;
    }

    await di<RoutingManager>().push(
      builder: (_) => AlbumPage(id: id),
      pageId: id.toString(),
    );
  }
}

class _AlbumsOfArtistGridView extends StatelessWidget with WatchItMixin {
  const _AlbumsOfArtistGridView({required this.artist});

  final String artist;

  @override
  Widget build(BuildContext context) => AlbumsView(
    albumIDs: watchValue(
      (AlbumIDsOfArtistManager m) => m.command,
      param1: artist,
    ),
  );
}

class _ArtistPageControlPanel extends StatelessWidget with WatchItMixin {
  const _ArtistPageControlPanel({required this.audios, required this.pageId});

  final List<Audio> audios;
  final String pageId;

  @override
  Widget build(BuildContext context) {
    final useGridView = watchValue(
      (FindTitlesOfArtistManager m) => m.useArtistGridView,
      param1: pageId,
    );
    final setUseGridView = di<FindTitlesOfArtistManager>(
      param1: pageId,
    ).setUseArtistGridView;

    onDispose(() => FindTitlesOfArtistManager.dispose(pageId));

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: space(
        children: [
          IconButton(
            icon: Icon(Iconz.grid),
            isSelected: useGridView,
            onPressed: () => setUseGridView(true),
          ),
          IconButton(
            icon: Icon(Iconz.list),
            isSelected: !useGridView,
            onPressed: () => setUseGridView(false),
          ),
          AvatarPlayButton(audios: audios, pageId: pageId),
          LikeAllIconButton(audios: audios),
          AudioTileOptionButton(
            audios: audios,
            playlistId: pageId,
            allowRemove: false,
            searchTerm: audios.firstOrNull?.artist ?? '',
            title: Text(audios.firstOrNull?.artist ?? ''),
            subTitle: Text(audios.firstOrNull?.genre ?? ''),
          ),
        ],
      ),
    );
  }
}
