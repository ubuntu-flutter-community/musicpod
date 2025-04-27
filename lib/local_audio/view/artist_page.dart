import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/audio_tile_option_button.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/like_all_icon_button.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_audio_page_control_panel.dart';
import '../../common/view/sliver_audio_tile_list.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../local_audio_model.dart';
import 'album_page.dart';
import 'album_view.dart';
import 'artist_round_image_container.dart';
import 'genre_page.dart';

class ArtistPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const ArtistPage({
    super.key,
    required this.pageId,
  });

  final String pageId;

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  late List<Audio> artistAudios;

  @override
  void initState() {
    super.initState();
    artistAudios =
        di<LocalAudioModel>().findTitlesOfArtist(widget.pageId) ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();

    final albumIDs = model.findAllAlbumIDs(artist: widget.pageId, clean: false);

    if (albumIDs == null) {
      return const SizedBox.shrink();
    }

    final useGridView =
        watchPropertyValue((LocalAudioModel m) => m.useArtistGridView);

    void onAlbumTap(text) {
      final audios = model.findAlbum(text);
      if (audios?.firstOrNull == null) return;
      final id = audios!.first.albumId;
      if (id == null) return;

      di<RoutingManager>().push(
        builder: (_) => AlbumPage(id: id),
        pageId: id,
      );
    }

    void onSubTitleTab(String text) => di<RoutingManager>().push(
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
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
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
                    title: widget.pageId,
                    image: ArtistRoundImageContainer(
                      artist: widget.pageId,
                      height: kMaxAudioPageHeaderHeight,
                      width: kMaxAudioPageHeaderHeight,
                    ),
                    subTitle: artistAudios.firstOrNull?.genre,
                    label: context.l10n.artist,
                    onLabelTab: onAlbumTap,
                    onSubTitleTab: onSubTitleTab,
                  ),
                ),
              ),
              SliverAudioPageControlPanel(
                controlPanel: _ArtistPageControlPanel(
                  pageId: widget.pageId,
                  audios: artistAudios,
                ),
              ),
              if (useGridView)
                SliverPadding(
                  padding:
                      getAdaptiveHorizontalPadding(constraints: constraints)
                          .copyWith(
                    bottom: bottomPlayerPageGap,
                  ),
                  sliver: AlbumsView(
                    albumIDs: albumIDs,
                  ),
                )
              else
                SliverPadding(
                  padding:
                      getAdaptiveHorizontalPadding(constraints: constraints)
                          .copyWith(
                    bottom: bottomPlayerPageGap,
                  ),
                  sliver: SliverAudioTileList(
                    audios: artistAudios,
                    pageId: widget.pageId,
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
          LikeAllIconButton(audios: audios),
          AudioTileOptionButton(
            audios: audios,
            playlistId: pageId,
            allowRemove: false,
            selected: false,
            searchTerm: audios.firstOrNull?.artist ?? '',
            title: Text(audios.firstOrNull?.artist ?? ''),
            subTitle: Text(audios.firstOrNull?.genre ?? ''),
          ),
        ],
      ),
    );
  }
}
