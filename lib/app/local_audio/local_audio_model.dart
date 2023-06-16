import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:mime_type/mime_type.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/music_app.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/utils.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:xdg_directories/xdg_directories.dart';

class LocalAudioModel extends SafeChangeNotifier {
  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery(String? value) {
    if (value == null || value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  Set<Audio>? _similarAlbumsSearchResult;
  Set<Audio>? get similarAlbumsSearchResult => _similarAlbumsSearchResult;
  void setSimilarAlbumsSearchResult(Set<Audio>? value) {
    _similarAlbumsSearchResult = value;
    notifyListeners();
  }

  Set<Audio>? _titlesSearchResult;
  Set<Audio>? get titlesSearchResult => _titlesSearchResult;
  void setTitlesSearchResult(Set<Audio>? value) {
    _titlesSearchResult = value;
    notifyListeners();
  }

  Set<Audio>? _similarArtistsSearchResult;
  Set<Audio>? get similarArtistsSearchResult => _similarArtistsSearchResult;
  void setSimilarArtistsSearchResult(Set<Audio>? value) {
    _similarArtistsSearchResult = value;
    notifyListeners();
  }

  void search() {
    if (searchQuery == null) return;

    final allAlbumsFindings = audios?.where(
      (audio) =>
          audio.album?.isNotEmpty == true &&
          audio.album!.toLowerCase().contains(searchQuery!.toLowerCase()),
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
          audio.artist!.toLowerCase().contains(searchQuery!.toLowerCase()),
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

    var titles = audios?.where(
          (audio) =>
              audio.title?.isNotEmpty == true &&
              audio.title!.toLowerCase().contains(searchQuery!.toLowerCase()),
        ) ??
        <Audio>{};
    setTitlesSearchResult(
      Set.from(
        titles,
      ),
    );
    setSimilarAlbumsSearchResult(albumsResult);
    setSimilarArtistsSearchResult(artistsResult);
  }

  Set<Audio> findAllArtists() {
    final artistsResult = <Audio>{};
    if (audios != null) {
      for (var a in audios!) {
        if (artistsResult.none(
          (e) => e.artist == a.artist,
        )) {
          artistsResult.add(a);
        }
      }
    }
    return artistsResult;
  }

  Set<Audio> findAllAlbums() {
    final albumsResult = <Audio>{};
    if (audios != null) {
      for (var a in audios!) {
        if (albumsResult.none((element) => element.album == a.album)) {
          albumsResult.add(a);
        }
      }
    }
    return albumsResult;
  }

  AudioFilter _audioFilter = AudioFilter.title;
  AudioFilter get audioFilter => _audioFilter;
  set audioFilter(AudioFilter value) {
    if (value == _audioFilter) return;
    _audioFilter = value;
    notifyListeners();
  }

  String? _directory;
  String? get directory => _directory;
  set directory(String? value) {
    if (value == null || value == _directory) return;
    _directory = value;
    _write({kDirectoryProperty: value}, 'settings.json')
        .then((_) => notifyListeners());
  }

  Set<Audio>? _audios;
  Set<Audio>? get audios => _audios;
  set audios(Set<Audio>? value) {
    _audios = value;
    notifyListeners();
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

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;
  set selectedTab(int value) {
    if (value == _selectedTab) return;
    _selectedTab = value;
    notifyListeners();
  }

  Future<void> init() async {
    _directory = (await _read('settings.json'))[kDirectoryProperty];
    _directory ??= getUserDirectory('MUSIC')?.path;

    if (_directory != null) {
      final allFileSystemEntities = Set<FileSystemEntity>.from(
        await _getFlattenedFileSystemEntities(path: directory!),
      );

      final onlyFiles = <FileSystemEntity>[];

      for (var fileSystemEntity in allFileSystemEntities) {
        if (!await FileSystemEntity.isDirectory(fileSystemEntity.path) &&
            validType(fileSystemEntity.path)) {
          onlyFiles.add(fileSystemEntity);
        }
      }

      int failures = 0;
      int total = 0;
      audios = {};
      for (var e in onlyFiles) {
        total++;
        try {
          final metadata = await MetadataGod.readMetadata(file: e.path);

          final audio = Audio(
            path: e.path,
            audioType: AudioType.local,
            artist: metadata.artist,
            title: metadata.title,
            album:
                '${metadata.album} ${metadata.discTotal != null && metadata.discTotal! > 1 ? metadata.discNumber : ''}',
            albumArtist: metadata.albumArtist,
            discNumber: metadata.discNumber,
            discTotal: metadata.discTotal,
            durationMs: metadata.durationMs,
            fileSize: metadata.fileSize,
            genre: metadata.genre,
            pictureData: metadata.picture?.data,
            pictureMimeType: metadata.picture?.mimeType,
            trackNumber: metadata.trackNumber,
            year: metadata.year,
          );

          audios?.add(audio);
        } catch (e) {
          failures++;
        }
      }
      if (failures > 0) {
        MusicApp.scaffoldKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Failed to import $failures of $total audio files.'),
          ),
        );
      }
      notifyListeners();
    }
  }

  bool validType(String path) => mime(path)?.contains('audio') ?? false;

  Future<List<FileSystemEntity>> _getFlattenedFileSystemEntities({
    required String path,
  }) async {
    return await Directory(path)
        .list(recursive: true, followLinks: false)
        .toList();
  }

  Future<void> _write(Map<String, String> map, String fileName) async {
    final jsonStr = jsonEncode(map);

    final workingDir = '${configHome.path}/$kMusicPodConfigSubDir';
    if (!Directory(workingDir).existsSync()) {
      await Directory(workingDir).create();
    }
    final path = '$workingDir/$fileName';

    final file = File(path);

    if (!file.existsSync()) {
      file.create();
    }

    await file.writeAsString(jsonStr);
  }

  Future<Map<String, String>> _read(String fileName) async {
    final workingDir = '${configHome.path}/musicpod';
    final path = '$workingDir/$fileName';
    final file = File(path);

    if (file.existsSync()) {
      final jsonStr = await file.readAsString();

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      final m = map.map(
        (key, value) => MapEntry<String, String>(
          key,
          value,
        ),
      );

      return m;
    } else {
      return <String, String>{};
    }
  }
}
