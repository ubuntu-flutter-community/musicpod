import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/explore_online_popup.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/like_all_icon.dart';
import '../../common/view/round_image_container.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_audio_page_control_panel.dart';
import '../../common/view/sliver_audio_tile_list.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../local_audio_model.dart';
import 'album_page.dart';
import 'album_view.dart';
import 'genre_page.dart';
import 'local_audio_search_page.dart';

class ArtistPage extends StatelessWidget with WatchItMixin {
  const ArtistPage({
    super.key,
    required this.images,
    required this.artistAudios,
  });

  final Set<Uint8List>? images;
  final Set<Audio>? artistAudios;

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();
    final pageId = artistAudios?.firstOrNull?.artist;
    final albums = model.findAllAlbums(newAudios: artistAudios, clean: false);

    if (pageId == null || albums == null) {
      return const SizedBox.shrink();
    }

    final useGridView = watchPropertyValue((AppModel m) => m.useArtistGridView);

    void onAlbumTap(text) {
      final audios = model.findAlbum(Audio(album: text));
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
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        title: isMobile ? null : Text(pageId),
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                di<LibraryModel>().push(
                  builder: (_) => const LocalAudioSearchPage(),
                  pageId: kSearchPageId,
                );
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
                    image: RoundImageContainer(
                      images: images,
                      fallBackText: pageId,
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
                    sliver: true,
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

  final Set<Audio> audios;
  final String pageId;

  @override
  Widget build(BuildContext context) {
    final useGridView = watchPropertyValue((AppModel m) => m.useArtistGridView);
    final setUseGridView = di<AppModel>().setUseArtistGridView;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Iconz().grid,
            color: useGridView ? context.t.colorScheme.primary : null,
          ),
          isSelected: useGridView,
          onPressed: () => setUseGridView(true),
        ),
        IconButton(
          icon: Icon(
            Iconz().list,
            color: !useGridView ? context.t.colorScheme.primary : null,
          ),
          isSelected: !useGridView,
          onPressed: () => setUseGridView(false),
        ),
        AvatarPlayButton(audios: audios, pageId: pageId),
        LikeAllIcon(audios: audios),
        ExploreOnlinePopup(text: pageId),
      ],
    );
  }
}
