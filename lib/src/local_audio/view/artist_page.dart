import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../data.dart';
import '../../../local_audio.dart';
import '../../../settings.dart';
import '../../common/explore_online_popup.dart';
import '../../common/sliver_audio_page_control_panel.dart';
import '../../common/sliver_audio_tile_list.dart';
import '../../l10n/l10n.dart';
import 'genre_page.dart';

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
    final albums = model.findAllAlbums(newAudios: artistAudios);

    if (pageId == null || albums == null) {
      return const SizedBox.shrink();
    }

    final useGridView =
        watchPropertyValue((SettingsModel m) => m.useArtistGridView);

    void onAlbumTap(text) {
      final audios = model.findAlbum(Audio(album: text));
      if (audios?.firstOrNull == null) return;
      final id = audios!.first.albumId;
      if (id == null) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return AlbumPage(
              id: id,
              album: audios,
            );
          },
        ),
      );
    }

    void onSubTitleTab(text) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return GenrePage(genre: text);
          },
        ),
      );
    }

    return YaruDetailPage(
      appBar: HeaderBar(
        adaptive: true,
        title: Text(pageId),
      ),
      body: AdaptiveContainer(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
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
            SliverAudioPageControlPanel(
              controlPanel: _ArtistPageControlPanel(
                pageId: pageId,
                audios: artistAudios!,
              ),
            ),
            if (useGridView)
              AlbumsView(
                sliver: true,
                albums: albums,
              )
            else
              SliverAudioTileList(
                audios: artistAudios!,
                pageId: pageId,
                audioPageType: AudioPageType.artist,
                onSubTitleTab: onAlbumTap,
              ),
          ],
        ),
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
    final useGridView =
        watchPropertyValue((SettingsModel m) => m.useArtistGridView);
    final setUseGridView = di<SettingsModel>().setUseArtistGridView;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarPlayButton(audios: audios, pageId: pageId),
        const SizedBox(
          width: 10,
        ),
        IconButton(
          icon: Icon(
            Iconz().list,
            color: !useGridView ? context.t.colorScheme.primary : null,
          ),
          isSelected: !useGridView,
          onPressed: () => setUseGridView(false),
        ),
        IconButton(
          icon: Icon(
            Iconz().grid,
            color: useGridView ? context.t.colorScheme.primary : null,
          ),
          isSelected: useGridView,
          onPressed: () => setUseGridView(true),
        ),
        ExploreOnlinePopup(text: pageId),
      ],
    );
  }
}
