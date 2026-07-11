import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:synchronized/synchronized.dart';

import '../../common/data/audio.dart';
import '../../common/logging.dart';
import '../../common/view/audio_filter.dart';
import '../../extensions/media_file_x.dart';
import '../../extensions/platform_x.dart';
import '../../settings/service/settings_service.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../data/change_metadata_capsule.dart';
import 'local_cover_service.dart';
import '../data/local_search_result.dart';
import '../persistence/local_audio_dao.dart';
import '../data/playlist_action.dart';

@Injectable(cache: true)
class LocalAudioService {
  final SettingsService _settingsService;
  final LocalAudioDao _dao;

  LocalAudioService({
    required LocalCoverService localCoverService,
    required SettingsService settingsService,
    required LocalAudioDao localAudioDao,
  }) : _settingsService = settingsService,
       _dao = localAudioDao {
    Logger.o(tag: '$LocalAudioService');
  }

  Future<List<Audio>> findAllTracks() => _dao.findAllTracks();

  Future<List<String>?> findAllArtists() => _dao.findAllArtists();

  Future<List<String>?> findAllGenres() => _dao.findAllGenres();

  Future<List<int>?> findAllAlbumIDs() => _dao.findAllAlbumIDs();

  Future<int?> findAlbumIdForArtistAndAlbum({
    required String artist,
    required String album,
  }) => _dao.findAlbumIdForArtistAndAlbum(artist: artist, album: album);

  Future<String?> findAlbumName(int albumId) => _dao.findAlbumName(albumId);

  Future<String?> findArtistOfAlbum(int albumId) =>
      _dao.findArtistOfAlbum(albumId);

  Future<List<Audio>?> findAlbum(
    int albumId, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) => _dao.loadAlbum(albumId);

  Future<List<int>> findAlbumIDsOfArtist(String artist) async =>
      _dao.findAlbumIDsOfArtist(artist);

  Future<List<Audio>?> findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) => _dao.loadTitlesOfArtist(artist, audioFilter);

  Future<List<int>?> findAlbumIDsOfGenre(String genre) =>
      _dao.findAlbumIDsOfGenre(genre);

  Future<LocalSearchResult?> search(String query) => _dao.search(query);

  final Lock _lock = Lock();
  Future<({List<String> failedImports})> init({
    String? newDirectory,
    bool forceInit = false,
    Function(double progress)? updateProgress,
  }) async {
    List<String> failedImports = [];
    updateProgress?.call(0.25);
    await Future<void>.delayed(Duration.zero);

    await _lock.synchronized(() async {
      final bool hasDataInDb = await _dao.getTrackCount() > 0;
      if (hasDataInDb && !forceInit) {
        updateProgress?.call(1);
        Logger.i(
          'Loading local audio library from database only, skipping directory scan.',
          tag: '$LocalAudioService',
        );
        return (failedImports: failedImports);
      }

      Logger.i(
        'Wiping local audio library if present and scanning directory for new audio files.',
        tag: '$LocalAudioService',
      );
      await _wipeLocalAudioLibrary();

      final dir =
          newDirectory ??
          _settingsService.getString(SPKeys.directory) ??
          PlatformX.musicDefaultDir;

      if (dir != null) {
        await _settingsService.setValue(SPKeys.directory, dir);
        final result = await compute(_readAudiosFromDirectory, dir);
        updateProgress?.call(0.5);
        await Future<void>.delayed(Duration.zero);
        failedImports = result.failedImports;

        await _dao.persistAudios(result.audios);
      }
      updateProgress?.call(0.75);
      await Future<void>.delayed(Duration.zero);

      updateProgress?.call(1);
      await Future<void>.delayed(Duration.zero);
    });

    return (failedImports: failedImports);
  }

  Future<bool> areTracksSynced() async {
    final dir = _settingsService.getString(SPKeys.directory);
    if (dir == null || dir.isEmpty) return true;
    final trackCount = await _dao.getTrackCount();
    final results = await _readMediaFilesFromDirectory(dir);
    return trackCount == results.files.length;
  }

  // ── Local Audio Library ──

  Future<void> _wipeLocalAudioLibrary() => _dao.wipeAllLocalAudioTables();

  // ── Liked Audios ──

  Future<List<Audio>> findLikedAudios() => _dao.findLikedAudios();

  Future<void> createOrChangeLikedAudios(PlaylistChange change) async {
    if (change.audios != null &&
        change.audios!.isNotEmpty &&
        (change.action == PlaylistAction.addTo ||
            change.action == PlaylistAction.replaceWith ||
            change.action == PlaylistAction.create)) {
      await _dao.persistAudios(change.audios!);
    }
    if (change.action == PlaylistAction.addTo && change.audios != null) {
      await addLikedAudios(change.audios!);
    } else if (change.action == PlaylistAction.replaceWith &&
        change.audios != null) {
      await removeLikedAudios(change.audios!);
      await addLikedAudios(change.audios!);
    } else if (change.action == PlaylistAction.removeFrom &&
        change.audios != null) {
      await removeLikedAudios(change.audios!);
    }
  }

  Future<void> addLikedAudios(List<Audio> audios) async {
    await _dao.addLikedAudiosToDb(audios);
  }

  Future<bool> isLikedAudios(List<Audio> audios) => _dao.areAudiosLiked(audios);

  Future<void> removeLikedAudios(List<Audio> audios) =>
      _dao.removeLikedAudios(audios);

  // ── Playlists ──

  Future<List<Audio>?> findPlaylistById(String id) => _dao.findPlaylistById(id);

  Future<List<String>> findAllPlaylistIDs() async => _dao.findAllPlaylistIDs();

  Future<bool> isPlaylistSaved(String? id) async =>
      id == null ? false : await _dao.isPlaylistSaved(id);

  Future<void> createOrChangePlaylist(PlaylistChange change) async {
    if (change.audios != null &&
        change.audios!.isNotEmpty &&
        (change.action == PlaylistAction.addTo ||
            change.action == PlaylistAction.replaceWith ||
            change.action == PlaylistAction.create)) {
      await _dao.persistAudios(change.audios!);
    }
    if (!await isPlaylistSaved(change.id)) {
      if (change.action == PlaylistAction.create) {
        await _createPlaylist(
          id: change.id,
          audios: change.audios ?? [],
          external: change.external,
        );
      }
    } else {
      if (change.action == PlaylistAction.addTo && change.audios != null) {
        await _addAudiosToPlaylist(id: change.id, newAudios: change.audios!);
      } else if (change.action == PlaylistAction.replaceWith &&
          change.audios != null) {
        await _replacePlaylist(change.id, change.audios!);
      } else if (change.action == PlaylistAction.removeFrom &&
          change.audios != null) {
        await _removeAudiosFromPlaylist(id: change.id, audios: change.audios!);
      } else if (change.action == PlaylistAction.moveWithin) {
        if (change.oldIndex != null && change.newIndex != null) {
          await _moveAudioInPlaylist(
            oldIndex: change.oldIndex!,
            newIndex: change.newIndex!,
            id: change.id,
          );
        }
      } else if (change.action == PlaylistAction.updateName &&
          change.newName != null) {
        await _updatePlaylistName(change.id, change.newName!);
      } else if (change.action == PlaylistAction.delete) {
        await removePlaylist(change.id);
      }
    }
  }

  Future<void> _createPlaylist({
    required String id,
    required List<Audio> audios,
    bool external = false,
  }) async {
    final localAudios = audios.where((e) => e.isLocal).toList();

    await _dao.createPlaylistInDb(
      name: id,
      audios: localAudios,
      external: external,
    );
  }

  Future<void> removePlaylist(String id) async {
    await _dao.deletePlaylist(id);
  }

  Future<void> _updatePlaylistName(String oldName, String newName) async {
    if (newName == oldName) return;
    await _dao.updatePlaylistNameInDb(oldName, newName);
  }

  Future<void> _moveAudioInPlaylist({
    required int oldIndex,
    required int newIndex,
    required String id,
  }) async => _dao.moveAudioInPlaylist(id, oldIndex, newIndex);

  Future<void> _persistPlaylist(String name, List<Audio> audios) async {
    await _dao.persistPlaylistInDb(name, audios);
  }

  Future<void> _replacePlaylist(String id, List<Audio> newAudios) async {
    await _persistPlaylist(id, newAudios.where((e) => e.isLocal).toList());
  }

  Future<void> _addAudiosToPlaylist({
    required String id,
    required List<Audio> newAudios,
  }) async {
    final playlist = await findPlaylistById(id);
    if (playlist == null) return;
    if (playlist.toSet().containsAll(newAudios)) {
      return;
    }

    try {
      for (var audio in newAudios) {
        if (!playlist.contains(audio) && audio.isLocal) {
          playlist.add(audio);
        }
      }
      await _persistPlaylist(id, playlist);
    } on Exception catch (e, s) {
      Logger.i(e, trace: s, tag: '$LocalAudioService');
    }
  }

  Future<void> _removeAudiosFromPlaylist({
    required String id,
    required List<Audio> audios,
  }) async {
    final playlist = await findPlaylistById(id);
    if (playlist == null) return;
    if (playlist.toSet().intersection(audios.toSet()).isEmpty) {
      return;
    }

    try {
      for (var audio in audios) {
        if (playlist.contains(audio)) {
          playlist.remove(audio);
        }
      }
      await _persistPlaylist(id, playlist);
    } on Exception catch (e, s) {
      Logger.i(e, trace: s, tag: '$LocalAudioService');
    }
  }

  // ── Pinned Albums ──

  Future<List<int>> findPinnedAlbumIDs() => _dao.findPinnedAlbumIDs();

  Future<bool> isPinnedAlbum(int id) => _dao.isAlbumPinned(id);

  Future<void> pinAlbum(int id) => _dao.updateAlbumPinned(id, true);

  Future<void> unpinAlbum(int id) async {
    if (!await isPinnedAlbum(id)) return;
    await _dao.updateAlbumPinned(id, false);
  }

  Future<List<int>> togglePinAlbum(int? id) async {
    if (id != null) {
      if (await isPinnedAlbum(id)) {
        await unpinAlbum(id);
      } else {
        await pinAlbum(id);
      }
    }
    return findPinnedAlbumIDs();
  }

  Future<Audio?> changeMetadata(
    Audio audio,
    ChangeMetadataCapsule capsule,
  ) async {
    Audio? updatedAudio;

    if (audio.path == null) {
      throw Exception('Cannot change metadata of audio without file path');
    }

    try {
      await compute(
        (capsule) => _updateMetadata(audio, capsule),
        ChangeMetadataCapsule(
          title: capsule.title,
          artist: capsule.artist,
          album: capsule.album,
          genre: capsule.genre,
          discTotal: capsule.discTotal,
          discNumber: capsule.discNumber,
          trackNumber: capsule.trackNumber,
          durationMs: capsule.durationMs,
          year: capsule.year,
          pictures: capsule.pictures,
        ),
      );

      final albumDbId = await _dao.updateSingleTrackInDb(
        audio,
        artist: capsule.artist,
        album: capsule.album,
        genre: capsule.genre,
        title: capsule.title,
        discNumber: capsule.discNumber,
        trackNumber: capsule.trackNumber,
        year: capsule.year,
        pictures: capsule.pictures,
      );

      // Return the updated Audio so reactive views (e.g. the metadata tiles
      // watching the change command) can reflect the persisted values.
      updatedAudio = audio.copyWith(
        title: capsule.title,
        artist: capsule.artist,
        albumArtist: capsule.artist,
        album: capsule.album,
        genre: capsule.genre,
        trackNumber: capsule.trackNumber == null
            ? null
            : int.tryParse(capsule.trackNumber!),
        discNumber: capsule.discNumber == null
            ? null
            : int.tryParse(capsule.discNumber!),
        discTotal: capsule.discTotal == null
            ? null
            : int.tryParse(capsule.discTotal!),
        year: capsule.year == null ? null : int.tryParse(capsule.year!),
        durationMs: capsule.durationMs == null
            ? null
            : double.tryParse(capsule.durationMs!),
        albumDbId: albumDbId,
      );
    } on Exception catch (e, s) {
      Logger.e(e, trace: s, tag: '$LocalAudioService');
    }

    return updatedAudio;
  }
}

FutureOr<ImportResult> _readAudiosFromDirectory(String? directory) async {
  final List<Audio> newAudios = [];
  final List<String> failedImports = [];

  if (directory != null && Directory(directory).existsSync()) {
    final results = await _readMediaFilesFromDirectory(directory);
    failedImports.addAll(results.failedImports);

    for (final e in results.files) {
      try {
        newAudios.add(Audio.local(e, onError: (p) => failedImports.add(p)));
      } on Exception catch (ex, s) {
        failedImports.add(e.path);
        Logger.e(ex, trace: s, tag: '$LocalAudioService');
      }
    }
  }

  Logger.i(
    'Finished reading audios from directory. Found ${newAudios.length} audios, with ${failedImports.length} failed imports.',
    tag: '$LocalAudioService',
  );

  return (audios: newAudios, failedImports: failedImports);
}

Future<({Iterable<File> files, List<String> failedImports})>
_readMediaFilesFromDirectory(String directory) async {
  final failedImports = <String>[];

  final files =
      (await Directory(directory)
              .list(recursive: true, followLinks: false)
              .handleError((e) => failedImports.add(e.toString()))
              .toList())
          .whereType<File>()
          .where((file) => file.isPlayable);

  return (files: files, failedImports: failedImports);
}

typedef ImportResult = ({List<String> failedImports, List<Audio> audios});

void _updateMetadata(Audio audio, ChangeMetadataCapsule capsule) {
  if (audio.path == null) {
    throw Exception('Audio path is null, cannot update metadata');
  }
  updateMetadata(File(audio.path!), (metadata) {
    if (capsule.title != null) {
      metadata.setTitle(capsule.title);
    }
    if (capsule.artist != null) {
      metadata.setArtist(capsule.artist);
    }
    if (capsule.album != null) {
      metadata.setAlbum(capsule.album);
    }
    if (capsule.genre != null) {
      metadata.setGenres([capsule.genre!]);
    }
    if (capsule.trackNumber != null &&
        int.tryParse(capsule.trackNumber!) != null) {
      metadata.setTrackNumber(int.tryParse(capsule.trackNumber!));
    }
    if (capsule.year != null && int.tryParse(capsule.year!) != null) {
      metadata.setYear(DateTime(int.parse(capsule.year!)));
    }
    if (capsule.pictures?.isNotEmpty ?? false) {
      metadata.setPictures(capsule.pictures!);
    }
  });
}
