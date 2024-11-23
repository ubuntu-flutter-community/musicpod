import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/music_pod_scaffold.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/audio_tile.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/fall_back_header_image.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_audio_page_control_panel.dart';
import '../../common/view/sliver_audio_tile_list.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/media_file_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../local_audio/view/album_page.dart';
import '../../local_audio/view/artist_page.dart';
import '../../local_audio/view/genre_page.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import 'manual_add_dialog.dart';
import 'playlst_add_audios_dialog.dart';

class PlaylistPage extends StatelessWidget with WatchItMixin {
  const PlaylistPage({
    super.key,
    required this.pageId,
  });

  final String pageId;

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();
    final libraryModel = di<LibraryModel>();
    final playlist = libraryModel.getPlaylistById(pageId);
    // This is needed to be notified about both size changes and also reordering
    watchPropertyValue((LibraryModel m) => m.playlists[pageId]?.length);
    watchPropertyValue((LibraryModel m) => m.playlists[pageId]?.hashCode);

    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropEnded: (e) async {
        Future.delayed(
          const Duration(milliseconds: 300),
        ).then(
          (_) => libraryModel.updatePlaylist(pageId, playlist ?? []),
        );
      },
      onPerformDrop: (e) async {
        for (var item in e.session.items.take(100)) {
          item.dataReader?.getValue(
            Formats.fileUri,
            (value) async {
              if (value == null) return;
              final file = File.fromUri(value);
              if (file.isValidMedia) {
                final data = readMetadata(file, getImage: true);
                var audio = Audio.fromMetadata(path: file.path, data: data);
                playlist?.add(audio);
              }
            },
            onError: (_) {},
          );
        }
      },
      onDropOver: (event) {
        if (event.session.allowedOperations.contains(DropOperation.copy)) {
          return DropOperation.copy;
        } else {
          return DropOperation.none;
        }
      },
      child: MusicPodScaffold(
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
                    ..setSearchType(SearchType.localTitle)
                    ..search();
                },
              ),
            ),
          ],
        ),
        body: _PlaylistPageBody(
          onAlbumTap: (text) {
            final albumAudios = model.findAlbum(text);
            if (albumAudios?.firstOrNull == null) return;
            final id = albumAudios!.first.albumId;
            if (id == null) return;
            di<LibraryModel>().push(
              builder: (_) {
                return AlbumPage(
                  id: id,
                  album: albumAudios,
                );
              },
              pageId: id,
            );
          },
          onArtistTap: (text) {
            final artistAudios = model.findTitlesOfArtist(text);
            final artist = artistAudios?.firstOrNull?.artist;
            if (artist == null) return;

            di<LibraryModel>().push(
              builder: (_) => ArtistPage(artistAudios: artistAudios),
              pageId: artist,
            );
          },
          image: _PlaylistHeaderImage(
            playlist: playlist ?? [],
            pageId: pageId,
          ),
          audios: playlist ?? [],
          pageId: pageId,
        ),
      ),
    );
  }
}

class _PlaylistHeaderImage extends StatelessWidget {
  const _PlaylistHeaderImage({
    required this.playlist,
    required this.pageId,
  });

  final String pageId;
  final List<Audio> playlist;

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();
    final playlistImages = model.findLocalCovers(audios: playlist, limit: 16);
    final length = playlistImages == null ? 0 : playlistImages.take(16).length;

    final padding = length == 1 ? 0.0 : 8.0;
    final spacing = length == 1 ? 0.0 : 16.0;
    final width = length == 1
        ? kMaxAudioPageHeaderHeight
        : length < 10
            ? 50.0
            : 32.0;
    final height = length == 1
        ? kMaxAudioPageHeaderHeight
        : length < 10
            ? 50.0
            : 32.0;
    final radius = length == 1 ? 0.0 : width / 2;

    Widget image;
    if (length == 0) {
      image = Icon(
        Iconz.playlist,
        size: 65,
      );
    } else {
      image = Center(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(
              length,
              (index) => ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Image.memory(
                  playlistImages!.elementAt(index),
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return FallBackHeaderImage(
      color: getAlphabetColor(pageId),
      child: image,
    );
  }
}

class _PlaylistPageBody extends StatelessWidget with WatchItMixin {
  const _PlaylistPageBody({
    required this.pageId,
    required this.audios,
    this.image,
    this.onAlbumTap,
    this.onArtistTap,
  });

  final String pageId;
  final List<Audio> audios;
  final Widget? image;

  final void Function(String text)? onAlbumTap;
  final void Function(String text)? onArtistTap;

  @override
  Widget build(BuildContext context) {
    final allowReorder =
        watchPropertyValue((LocalAudioModel m) => m.allowReorder);
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final libraryModel = di<LibraryModel>();
    final playerModel = di<PlayerModel>();
    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);

    final audioPageHeader = AudioPageHeader(
      title: pageId,
      subTitle: '${audios.length} ${context.l10n.titles}',
      image: image,
      label: context.l10n.playlist,
      description: _PlaylistGenreBar(audios: audios),
    );

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
                child: audioPageHeader,
              ),
            ),
            SliverAudioPageControlPanel(
              controlPanel:
                  _PlaylistControlPanel(pageId: pageId, audios: audios),
            ),
            if (allowReorder)
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(
                  constraints: constraints,
                  min: 40,
                ),
                sliver: SliverReorderableList(
                  itemCount: audios.length,
                  itemBuilder: (BuildContext context, int index) {
                    final audio = audios.elementAt(index);
                    final audioSelected = currentAudio == audio;

                    return ReorderableDragStartListener(
                      key: ValueKey(audio.path ?? audio.url),
                      index: index,
                      child: AudioTile(
                        showLeading: audios.length < kShowLeadingThreshold,
                        onSubTitleTap: onArtistTap,
                        key: ValueKey(audio.path ?? audio.url),
                        isPlayerPlaying: isPlaying,
                        onTap: () => playerModel.startPlaylist(
                          audios: audios,
                          listName: pageId,
                          index: index,
                        ),
                        selected: audioSelected,
                        audio: audio,
                        pageId: pageId,
                        audioPageType: AudioPageType.playlist,
                      ),
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    if (playerModel.queueName == pageId) {
                      playerModel.moveAudioInQueue(oldIndex, newIndex);
                    }

                    libraryModel.moveAudioInPlaylist(
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                      id: pageId,
                    );
                  },
                ),
              )
            else
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(constraints: constraints),
                sliver: SliverAudioTileList(
                  audios: audios,
                  pageId: pageId,
                  audioPageType: AudioPageType.playlist,
                  onSubTitleTab: onArtistTap,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PlaylistControlPanel extends StatelessWidget with WatchItMixin {
  const _PlaylistControlPanel({
    required this.pageId,
    required this.audios,
  });

  final String pageId;
  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final allowReorder =
        watchPropertyValue((LocalAudioModel m) => m.allowReorder);
    final libraryModel = di<LibraryModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: space(
        children: [
          IconButton(
            tooltip: context.l10n.editPlaylist,
            icon: Icon(Iconz.pen),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: SizedBox(
                  height: 200,
                  width: 500,
                  child: PlaylistContent(
                    playlistName: pageId,
                    initialValue: pageId,
                    allowDelete: true,
                    allowRename: true,
                    libraryModel: libraryModel,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: context.l10n.clearPlaylist,
            icon: Icon(Iconz.clearAll),
            onPressed: () => libraryModel.clearPlaylist(pageId),
          ),
          AvatarPlayButton(audios: audios, pageId: pageId),
          IconButton(
            tooltip: context.l10n.add,
            icon: Icon(Iconz.plus),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => PlaylistAddAudiosDialog(playlistId: pageId),
            ),
          ),
          IconButton(
            tooltip: context.l10n.move,
            isSelected: allowReorder,
            onPressed: () =>
                di<LocalAudioModel>().setAllowReorder(!allowReorder),
            icon: Icon(Iconz.move),
          ),
        ],
      ),
    );
  }
}

class _PlaylistGenreBar extends StatelessWidget {
  const _PlaylistGenreBar({
    required this.audios,
  });

  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.pageHeaderDescription;
    Set<String> genres = {};
    for (var e in audios) {
      final g = e.genre?.trim();
      if (g?.isNotEmpty == true) {
        genres.add(g!);
      }
    }

    return SingleChildScrollView(
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: genres
            .mapIndexed(
              (i, e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TapAbleText(
                    style: style,
                    wrapInFlexible: false,
                    text: e,
                    onTap: () {
                      di<LibraryModel>().push(
                        builder: (context) => GenrePage(genre: e),
                        pageId: e,
                      );
                    },
                  ),
                  if (i != genres.length - 1) const Text(' · '),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
