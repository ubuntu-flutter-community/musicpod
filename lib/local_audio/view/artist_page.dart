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
import '../../common/view/genre_bar.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/like_all_icon_button.dart';
import '../../common/view/progress.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_audio_page_control_panel.dart';
import '../../common/view/sliver_audio_tile_list.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../local_audio_model.dart';
import 'album_page.dart';
import 'album_view.dart';
import 'artist_image.dart';
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
  late Future<List<Audio>?> _artistAudios;

  @override
  void initState() {
    super.initState();
    _artistAudios = di<LocalAudioModel>().findTitlesOfArtist(widget.pageId);
  }

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();

    final useGridView =
        watchPropertyValue((LocalAudioModel m) => m.useArtistGridView);

    void onAlbumTap(String text) {
      final id = model.findAlbumId(artist: widget.pageId, album: text);

      if (id == null) {
        showSnackBar(
          context: context,
          content: Text(context.l10n.nothingFound),
        );
        return;
      }

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
      body: FutureBuilder(
        future: _artistAudios,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Progress());
          }

          final artistAudios = snapshot.data!;

          return LayoutBuilder(
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
                        image: ArtistImage(
                          artist: widget.pageId,
                          dimension: kMaxAudioPageHeaderHeight,
                        ),
                        subTitleWidget: GenreBar(audios: artistAudios),
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
                        albumIDs: model.findAllAlbumIDs(
                          artist: widget.pageId,
                          clean: false,
                        ),
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
