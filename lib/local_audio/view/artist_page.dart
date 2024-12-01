import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/audio_tile_option_button.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/like_all_icon.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_audio_page_control_panel.dart';
import '../../common/view/sliver_audio_tile_list.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../local_audio_model.dart';
import 'album_page.dart';
import 'album_view.dart';
import 'artist_round_image_container.dart';
import 'genre_page.dart';

class ArtistPage extends StatelessWidget with WatchItMixin {
  const ArtistPage({
    super.key,
    required this.artistAudios,
  });

  final List<Audio>? artistAudios;

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();
    final pageId = artistAudios?.firstOrNull?.artist;
    final albums = model.findAllAlbums(newAudios: artistAudios, clean: false);

    if (pageId == null || albums == null) {
      return const SizedBox.shrink();
    }

    final useGridView =
        watchPropertyValue((LocalAudioModel m) => m.useArtistGridView);

    void onAlbumTap(text) {
      final audios = model.findAlbum(text);
      if (audios?.firstOrNull == null) return;
      final id = audios!.first.albumId;
      if (id == null) return;

      di<LibraryModel>().push(
        builder: (_) => AlbumPage(
          id: id,
          album: audios,
        ),
        pageId: id,
      );
    }

    void onSubTitleTab(String text) => di<LibraryModel>().push(
          builder: (context) => GenrePage(genre: text),
          pageId: text,
        );

    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                di<LibraryModel>().push(pageId: kSearchPageId);
                final searchmodel = di<SearchModel>();
                searchmodel
                  ..setAudioType(AudioType.local)
                  ..setSearchType(SearchType.localArtist)
                  ..search();
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(
                  constraints: constraints,
                  min: 40,
                ),
                sliver: SliverToBoxAdapter(
                  child: AudioPageHeader(
                    imageRadius: BorderRadius.circular(10000),
                    title: artistAudios?.firstOrNull?.artist ?? '',
                    image: ArtistRoundImageContainer(
                      artistAudios: artistAudios,
                      height: kMaxAudioPageHeaderHeight,
                      width: kMaxAudioPageHeaderHeight,
                    ),
                    subTitle: artistAudios?.firstOrNull?.genre,
                    label: context.l10n.artist,
                    onLabelTab: onAlbumTap,
                    onSubTitleTab: onSubTitleTab,
                  ),
                ),
              ),
              SliverAudioPageControlPanel(
                controlPanel: _ArtistPageControlPanel(
                  pageId: pageId,
                  audios: artistAudios!,
                ),
              ),
              if (useGridView)
                SliverPadding(
                  padding:
                      getAdaptiveHorizontalPadding(constraints: constraints),
                  sliver: AlbumsView(
                    albums: albums,
                  ),
                )
              else
                SliverPadding(
                  padding:
                      getAdaptiveHorizontalPadding(constraints: constraints),
                  sliver: SliverAudioTileList(
                    audios: artistAudios!,
                    pageId: pageId,
                    audioPageType: AudioPageType.artist,
                    onSubTitleTab: onAlbumTap,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ArtistPageControlPanel extends StatelessWidget with WatchItMixin {
  const _ArtistPageControlPanel({
    required this.audios,
    required this.pageId,
  });

  final List<Audio> audios;
  final String pageId;

  @override
  Widget build(BuildContext context) {
    final useGridView =
        watchPropertyValue((LocalAudioModel m) => m.useArtistGridView);
    final setUseGridView = di<LocalAudioModel>().setUseArtistGridView;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: space(
        children: [
          IconButton(
            icon: Icon(
              Iconz.grid,
            ),
            isSelected: useGridView,
            onPressed: () => setUseGridView(true),
          ),
          IconButton(
            icon: Icon(
              Iconz.list,
            ),
            isSelected: !useGridView,
            onPressed: () => setUseGridView(false),
          ),
          AvatarPlayButton(audios: audios, pageId: pageId),
          LikeAllIcon(audios: audios),
          AudioTileOptionButton(
            audios: audios,
            playlistId: pageId,
            allowRemove: false,
            selected: false,
            searchTerm: audios.first.artist ?? '',
            title: Text(audios.first.artist ?? ''),
            subTitle: Text(audios.first.genre ?? ''),
          ),
        ],
      ),
    );
  }
}
