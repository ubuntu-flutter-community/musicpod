import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/logging.dart';
import '../../common/page_ids.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/audio_tile.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_audio_page_control_panel.dart';
import '../../common/view/sliver_audio_tile_list.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../local_audio/view/album_page.dart';
import '../../local_audio/view/artist_page.dart';
import '../../local_audio/view/failed_import_snackbar.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import 'playlist_control_panel.dart';
import 'playlist_genre_bar.dart';
import 'playlist_header_image.dart';

class PlaylistPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PlaylistPage({
    super.key,
    required this.pageId,
  });

  final String pageId;

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  late List<Audio> playlist;

  static Map<String, List<Audio>> cache = {};

  @override
  void initState() {
    super.initState();
    getPlaylist();
  }

  void getPlaylist() {
    if (cache[widget.pageId]?.isNotEmpty == true) {
      playlist = cache[widget.pageId]!;
      return;
    }

    final playlistById =
        di<LibraryModel>().getPlaylistById(widget.pageId) ?? [];

    cache[widget.pageId] = playlistById;
    playlist = playlistById;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final model = di<LocalAudioModel>();
    final libraryModel = di<LibraryModel>();

    // This is needed to be notified about both size changes and also reordering
    watchPropertyValue(
      (LibraryModel m) {
        setState(() => getPlaylist());
        return m.getPlaylistById(widget.pageId)?.length;
      },
    );
    watchPropertyValue(
      (LibraryModel m) {
        setState(() => getPlaylist());
        return m.getPlaylistById(widget.pageId)?.hashCode;
      },
    );

    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropEnded: (e) async {
        Future.delayed(
          const Duration(milliseconds: 300),
        ).then(
          (_) =>
              libraryModel.updatePlaylist(id: widget.pageId, audios: playlist),
        );
      },
      onPerformDrop: (e) async {
        for (var item in e.session.items.take(100)) {
          item.dataReader?.getValue(
            Formats.fileUri,
            (value) async {
              if (value == null) return;
              try {
                final file = File.fromUri(value);
                playlist.add(
                  Audio.local(
                    file,
                    getImage: true,
                    onError: (path) => showFailedImportsSnackBar(
                      failedImports: [path],
                      context: context,
                      message: l10n.failedToImport,
                    ),
                    onParseError: (path) => showFailedImportsSnackBar(
                      failedImports: [path],
                      context: context,
                      message: l10n.failedToReadMetadata,
                    ),
                  ),
                );
              } on Exception catch (e) {
                printMessageInDebugMode(e);
                showFailedImportsSnackBar(
                  failedImports: [value.toString()],
                  context: context,
                  message: l10n.failedToImport,
                );
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
      child: Scaffold(
        appBar: HeaderBar(
          adaptive: true,
          actions: [
            Padding(
              padding: appBarSingleActionSpacing,
              child: SearchButton(
                onPressed: () {
                  di<LibraryModel>().push(pageId: PageIDs.searchPage);
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
                return AlbumPage(id: id);
              },
              pageId: id,
            );
          },
          onArtistTap: (text) => di<LibraryModel>().push(
            builder: (_) => ArtistPage(pageId: text),
            pageId: text,
          ),
          image: PlaylistHeaderImage(
            playlist: playlist,
            pageId: widget.pageId,
          ),
          audios: playlist,
          pageId: widget.pageId,
        ),
      ),
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
    final l10n = context.l10n;
    final allowReorder =
        watchPropertyValue((LocalAudioModel m) => m.allowReorder);
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final libraryModel = di<LibraryModel>();
    final playerModel = di<PlayerModel>();
    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);
    watchPropertyValue((LibraryModel m) => m.externalPlaylists.length);

    final audioPageHeader = AudioPageHeader(
      title: pageId,
      subTitle: '${audios.length} ${l10n.titles}',
      image: image,
      label: di<LibraryModel>().externalPlaylists.contains(pageId)
          ? '${l10n.playlist} (${l10n.external})'
          : l10n.playlist,
      description: PlaylistGenreBar(audios: audios),
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
                  PlaylistControlPanel(pageId: pageId, audios: audios),
            ),
            if (allowReorder)
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(
                  constraints: constraints,
                  min: 40,
                ).copyWith(
                  bottom: bottomPlayerPageGap,
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
                padding: getAdaptiveHorizontalPadding(
                  constraints: constraints,
                  min: 40,
                ),
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
