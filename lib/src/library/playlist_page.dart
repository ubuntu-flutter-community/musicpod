import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../../common.dart';
import '../../data.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../utils.dart';
import '../common/fall_back_header_image.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import 'playlst_add_audios_dialog.dart';

class PlaylistPage extends ConsumerWidget {
  const PlaylistPage({
    super.key,
    required this.playlist,
    required this.libraryModel,
  });

  final MapEntry<String, Set<Audio>> playlist;
  final LibraryModel libraryModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.read(localAudioModelProvider);
    final libraryModel = ref.read(libraryModelProvider);
    final failedImports = <String>[];
    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropEnded: (p0) {
        if (failedImports.isEmpty) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 10),
            content: FailedImportsContent(
              onNeverShowFailedImports: () {},
              failedImports: failedImports,
            ),
          ),
        );
      },
      onPerformDrop: (event) async {
        for (var item in event.session.items) {
          final reader = item.dataReader!;

          reader.getValue(
            Formats.fileUri,
            (value) {
              if (value == null) return;
              final file = File.fromUri(value);
              if (!isValidFile(file.path)) return;
              readMetadata(file, getImage: true).then(
                (data) {
                  libraryModel.addAudioToPlaylist(
                    playlist.key,
                    Audio.fromMetadata(path: file.path, data: data),
                  );
                },
              );
            },
            onError: (value) {
              failedImports.add(value.toString());
            },
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
      child: AudioPage(
        onAlbumTap: (text) {
          final albumAudios = model.findAlbum(Audio(album: text));
          if (albumAudios?.firstOrNull == null) return;
          final id = generateAlbumId(albumAudios!.first);
          if (id == null) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) {
                return AlbumPage(
                  isPinnedAlbum: libraryModel.isPinnedAlbum,
                  removePinnedAlbum: libraryModel.removePinnedAlbum,
                  addPinnedAlbum: libraryModel.addPinnedAlbum,
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
        showAudioTileHeader:
            playlist.value.any((e) => e.audioType != AudioType.podcast),
        audioPageType: AudioPageType.playlist,
        image: FallBackHeaderImage(
          color: getAlphabetColor(playlist.key),
          child: Icon(
            Iconz().playlist,
            size: 65,
          ),
        ),
        headerLabel: context.l10n.playlist,
        headerTitle: playlist.key,
        audios: playlist.value,
        pageId: playlist.key,
        noResultMessage: Text(context.l10n.emptyPlaylist),
        controlPanelButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: context.l10n.editPlaylist,
              icon: Icon(Iconz().pen),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => PlaylistDialog(
                  playlistName: playlist.key,
                  initialValue: playlist.key,
                  allowDelete: true,
                  allowRename: true,
                  libraryModel: libraryModel,
                ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.clearPlaylist,
              icon: Icon(Iconz().clearAll),
              onPressed: () => libraryModel.clearPlaylist(playlist.key),
            ),
            IconButton(
              tooltip: context.l10n.add,
              icon: Icon(Iconz().plus),
              onPressed: () => showDialog(
                context: context,
                builder: (context) =>
                    PlaylistAddAudiosDialog(playlistId: playlist.key),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
