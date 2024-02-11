import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../common.dart';
import '../../data.dart';
import '../../utils.dart';
import '../settings/settings_service.dart';

class LocalAudioService {
  final SettingsService settingsService;

  LocalAudioService({
    required this.settingsService,
  });

  final Signal<bool?> audiosChanged = signal(null);
  Set<Audio>? audios;

  Future<void> init({
    @visibleForTesting String? testDir,
    required void Function(List<String> failedImports) onFail,
    bool forceInit = false,
  }) async {
    if (forceInit || (audios == null || audios?.isEmpty == true)) {
      String? dir;
      if (testDir != null) {
        dir = testDir;
      } else {
        dir = settingsService.directory.value;
        dir ??= await getMusicDir();
      }
      final result = await compute(_init, dir);

      audios = result.$2;

      _allAlbums = _findAllAlbums();
      _allArtists = _findAllArtists();

      audiosChanged.value = true;

      final failedImports = result.$1;
      if (failedImports.isNotEmpty) {
        onFail(failedImports);
      }
    }
  }

  (Set<Audio>?, Set<Audio>?, Set<Audio>?)? searchResult;
  final Signal<bool?> searchResultChanged = signal(null);
  Signal<String?> searchQuery = signal(null);
  void search(String? query) {
    searchQuery.value = query;
    if (query == null) return;
    if (query.isEmpty) {
      searchResult = ({}, {}, {});
      searchResultChanged.value = true;

      return;
    }

    final allAlbumsFindings = audios?.where(
      (audio) =>
          audio.album?.isNotEmpty == true &&
          audio.album!.toLowerCase().contains(query.toLowerCase()),
    );

    final albumsResult = <Audio>{};
    if (allAlbumsFindings != null) {
      for (var a in allAlbumsFindings) {
        if (albumsResult.none((element) => element.album == a.album)) {
          albumsResult.add(a);
        }
      }
    }

    final allArtistFindings = audios?.where(
      (audio) =>
          audio.artist?.isNotEmpty == true &&
          audio.artist!.toLowerCase().contains(query.toLowerCase()),
    );
    final artistsResult = <Audio>{};
    if (allArtistFindings != null) {
      for (var a in allArtistFindings) {
        if (artistsResult.none(
          (e) => e.artist == a.artist,
        )) {
          artistsResult.add(a);
        }
      }
    }

    searchResult = (
      Set.from(
        audios?.where(
              (audio) =>
                  audio.title?.isNotEmpty == true &&
                  audio.title!.toLowerCase().contains(query.toLowerCase()),
            ) ??
            <Audio>[],
      ),
      albumsResult,
      artistsResult
    );
    searchResultChanged.value = true;
  }

  Set<Audio>? _allArtists;
  Set<Audio>? get allArtists => _allArtists;
  Set<Audio>? _findAllArtists() {
    if (audios == null) return null;
    final artistsResult = <Audio>{};
    for (var a in audios!) {
      if (artistsResult.none(
        (e) => e.artist == a.artist,
      )) {
        artistsResult.add(a);
      }
    }
    return artistsResult;
  }

  Set<Audio>? _allAlbums;
  Set<Audio>? get allAlbums => _allAlbums;
  Set<Audio>? _findAllAlbums() {
    if (audios == null) return null;
    final albumsResult = <Audio>{};
    for (var a in audios!) {
      if (albumsResult.none((element) => element.album == a.album)) {
        albumsResult.add(a);
      }
    }
    return albumsResult;
  }

  Set<Audio>? findAlbum(
    Audio audio, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) {
    final album = audios?.where(
      (a) => a.album != null && a.album == audio.album,
    );

    final albumList = album?.toList();
    if (albumList != null) {
      sortListByAudioFilter(
        audioFilter: audioFilter,
        audios: albumList,
      );
    }
    return albumList != null ? Set.from(albumList) : null;
  }

  Set<Audio>? findArtist(
    Audio audio, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) {
    final album = audios?.where(
      (a) => a.artist != null && a.artist == audio.artist,
    );

    final albumList = album?.toList();
    if (albumList != null) {
      sortListByAudioFilter(
        audioFilter: audioFilter,
        audios: albumList,
      );
    }
    return albumList != null ? Set.from(albumList) : null;
  }

  Set<Uint8List>? findImages(Set<Audio> audios) {
    final images = <Uint8List>{};
    final albumAudios = <Audio>{};
    for (var audio in audios) {
      if (albumAudios.none((a) => a.album == audio.album)) {
        albumAudios.add(audio);
      }
    }

    for (var audio in albumAudios) {
      if (audio.pictureData != null) {
        images.add(audio.pictureData!);
      }
    }

    return images;
  }
}

FutureOr<(List<String>, Set<Audio>?)> _init(String? directory) async {
  MetadataGod.initialize();
  Set<Audio>? newAudios = {};
  List<String> failedImports = [];

  if (directory != null) {
    final allFileSystemEntities = Set<FileSystemEntity>.from(
      await _getFlattenedFileSystemEntities(path: directory),
    );

    final onlyFiles = <FileSystemEntity>[];

    for (var fileSystemEntity in allFileSystemEntities) {
      if (!await FileSystemEntity.isDirectory(fileSystemEntity.path) &&
          isValidFile(fileSystemEntity.path)) {
        onlyFiles.add(fileSystemEntity);
      }
    }
    for (var e in onlyFiles) {
      try {
        final metadata = await MetadataGod.readMetadata(file: e.path);

        final audio = createLocalAudio(
          path: e.path,
          tag: metadata,
          fileName: File(e.path).uri.pathSegments.lastOrNull,
        );

        newAudios.add(audio);
      } catch (error) {
        failedImports.add(e.path);
      }
    }
  }

  return (failedImports, newAudios);
}

Future<List<FileSystemEntity>> _getFlattenedFileSystemEntities({
  required String path,
}) async {
  return await Directory(path)
      .list(recursive: true, followLinks: false)
      .toList();
}
