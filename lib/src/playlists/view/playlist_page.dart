import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:yaru/yaru.dart';

import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../constants.dart';
import '../../../data.dart';
import '../../../get.dart';
import '../../../library.dart';
import '../../../local_audio.dart';
import '../../../media_file_x.dart';
import '../../../playlists.dart';
import '../../common/fall_back_header_image.dart';
import '../../common/sliver_audio_page_control_panel.dart';
import '../../common/sliver_audio_tile_list.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/view/genre_page.dart';
import '../../player/player_model.dart';
import '../../theme.dart';
import 'playlst_add_audios_dialog.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({
    super.key,
    required this.playlist,
  });

  final MapEntry<String, Set<Audio>> playlist;

  @override
  Widget build(BuildContext context) {
    final model = getIt<LocalAudioModel>();
    final libraryModel = getIt<LibraryModel>();
    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropEnded: (e) async {
        Future.delayed(
          const Duration(milliseconds: 300),
        ).then(
          (_) => libraryModel.updatePlaylist(playlist.key, playlist.value),
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
                final data = await readMetadata(file, getImage: true);
                var audio = Audio.fromMetadata(path: file.path, data: data);
                playlist.value.add(audio);
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
      child: YaruDetailPage(
        appBar: HeaderBar(
          adaptive: true,
          title: Text(playlist.key),
        ),
        body: _PlaylistPageBody(
          onAlbumTap: (text) {
            final albumAudios = model.findAlbum(Audio(album: text));
            if (albumAudios?.firstOrNull == null) return;
            final id = albumAudios!.first.albumId;
            if (id == null) return;

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) {
                  return AlbumPage(
                    id: id,
                    album: albumAudios,
                  );
                },
              ),
            );
          },
          onArtistTap: (text) {
            final artistAudios = model.findArtist(Audio(artist: text));
            final images = model.findImages(artistAudios ?? {});

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) {
                  return ArtistPage(
                    images: images,
                    artistAudios: artistAudios,
                  );
                },
              ),
            );
          },
          image: PlaylistHeaderImage(playlist: playlist),
          audios: playlist.value,
          pageId: playlist.key,
        ),
      ),
    );
  }
}

class PlaylistHeaderImage extends StatelessWidget {
  const PlaylistHeaderImage({
    super.key,
    required this.playlist,
  });

  final MapEntry<String, Set<Audio>> playlist;

  @override
  Widget build(BuildContext context) {
    final model = getIt<LocalAudioModel>();
    final playlistImages = model.findImages(playlist.value);
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
        Iconz().playlist,
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
      color: getAlphabetColor(playlist.key),
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
  final Set<Audio> audios;
  final Widget? image;

  final void Function(String text)? onAlbumTap;
  final void Function(String text)? onArtistTap;

  @override
  Widget build(BuildContext context) {
    final localAudioModel = getIt<LocalAudioModel>();
    final allowReorder =
        watchPropertyValue((LocalAudioModel m) => m.allowReorder);
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final libraryModel = getIt<LibraryModel>();
    final playerModel = getIt<PlayerModel>();
    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);

    watchPropertyValue((LibraryModel m) => m.likedAudios.length);
    watchPropertyValue(
      (LibraryModel m) => m.playlists[pageId]?.length,
    );

    final audioControlPanel = Row(
      children: [
        AvatarPlayButton(audios: audios, pageId: pageId),
        const SizedBox(
          width: 10,
        ),
        IconButton(
          tooltip: context.l10n.editPlaylist,
          icon: Icon(Iconz().pen),
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
          icon: Icon(Iconz().clearAll),
          onPressed: () => libraryModel.clearPlaylist(pageId),
        ),
        IconButton(
          tooltip: context.l10n.add,
          icon: Icon(Iconz().plus),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => PlaylistAddAudiosDialog(playlistId: pageId),
          ),
        ),
        IconButton(
          tooltip: context.l10n.move,
          isSelected: allowReorder,
          onPressed: () => localAudioModel.setAllowReorder(!allowReorder),
          icon: Icon(
            Iconz().reorder,
            color: allowReorder ? context.t.colorScheme.primary : null,
          ),
        ),
      ],
    );

    final audioPageHeader = AudioPageHeader(
      title: pageId,
      image: image,
      label: context.l10n.playlist,
      descriptionWidget: _PlaylistGenreBar(audios: audios),
    );

    return AdaptiveContainer(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: audioPageHeader,
          ),
          SliverAudioPageControlPanel(controlPanel: audioControlPanel),
          if (allowReorder)
            SliverReorderableList(
              itemCount: audios.length,
              itemBuilder: (BuildContext context, int index) {
                final audio = audios.elementAt(index);
                final audioSelected = currentAudio == audio;

                return ReorderableDragStartListener(
                  key: ValueKey(audio.path ?? audio.url),
                  index: index,
                  child: AudioTile(
                    onSubTitleTap: onArtistTap,
                    key: ValueKey(audio.path ?? audio.url),
                    isPlayerPlaying: isPlaying,
                    pause: playerModel.pause,
                    startPlaylist: () => playerModel.startPlaylist(
                      audios: audios,
                      listName: pageId,
                      index: index,
                    ),
                    resume: playerModel.resume,
                    selected: audioSelected,
                    audio: audio,
                    insertIntoQueue: playerModel.insertIntoQueue,
                    pageId: pageId,
                    libraryModel: libraryModel,
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
            )
          else
            SliverAudioTileList(
              audios: audios,
              pageId: pageId,
              audioPageType: AudioPageType.playlist,
              onSubTitleTab: onArtistTap,
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

  final Set<Audio> audios;

  @override
  Widget build(BuildContext context) {
    Set<String> genres = {};
    for (var e in audios) {
      final g = e.genre?.trim();
      if (g?.isNotEmpty == true) {
        genres.add(g!);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 5, left: 2),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: genres
            .mapIndexed(
              (i, e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TapAbleText(
                    wrapInFlexible: false,
                    text: e,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return GenrePage(genre: e);
                          },
                        ),
                      );
                    },
                  ),
                  if (i != genres.length - 1) const Text(', '),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
