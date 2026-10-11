import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../../dependencies.dart';
import '../../extensions/build_context_x.dart';
import '../../search/data/search_type.dart';
import '../../search/manager/search_manager.dart';
import '../manager/album_ids_of_artist_manager.dart';
import '../manager/artist_grid_view_manager.dart';
import '../manager/find_titles_of_artist_manager.dart';
import '../service/local_audio_service.dart';
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

class _ArtistPageBody extends ConsumerWidget {
  const _ArtistPageBody({required this.pageId});

  final String pageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useGridView = ref.watch(artistGridViewManagerProvider(pageId));
    final results = ref.watch(findTitlesOfArtistManagerProvider(pageId));

    if (results.isLoading) {
      return const Center(child: Progress());
    }

    if (results.hasError) {
      return Center(child: Text(results.error.toString()));
    }

    final artistAudios = results.value ?? [];

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
              audioPageType: AudioPageType.artist,
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
    final id = await di<LocalAudioService>().findAlbumIdForArtistAndAlbum(
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

class _AlbumsOfArtistGridView extends ConsumerWidget {
  const _AlbumsOfArtistGridView({required this.artist});

  final String artist;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlbumsView(
    albumIDs: ref.watch(albumIDsOfArtistManagerProvider(artist)).value,
  );
}

class _ArtistPageControlPanel extends ConsumerWidget {
  const _ArtistPageControlPanel({
    required this.audios,
    required this.pageId,
  });

  final List<Audio> audios;
  final String pageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useGridView = ref.watch(artistGridViewManagerProvider(pageId));

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: space(
        children: [
          IconButton(
            icon: Icon(Iconz.grid),
            isSelected: useGridView,
            onPressed: () => ref
                .read(artistGridViewManagerProvider(pageId).notifier)
                .setUseArtistGridView(true),
          ),
          IconButton(
            icon: Icon(Iconz.list),
            isSelected: !useGridView,
            onPressed: () => ref
                .read(artistGridViewManagerProvider(pageId).notifier)
                .setUseArtistGridView(false),
          ),
          AvatarPlayButton(
            pageId: pageId,
            audioPageType: AudioPageType.artist,
          ),
          LikeAllIconButton(audios: audios),
          AudioTileOptionButton(
            audios: audios,
            playlistId: pageId,
            allowRemove: false,
            searchTerm: pageId,
            title: Text(pageId),
            subTitle: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
