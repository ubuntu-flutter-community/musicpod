import 'dart:async';
import 'dart:io';

import 'package:metadata_god/metadata_god.dart';
import 'package:mime_type/mime_type.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/utils.dart';
import 'package:xdg_directories/xdg_directories.dart';

class LocalAudioService {
  String? _directory;
  String? get directory => _directory;
  Future<void> setDirectory(String? value) async {
    if (value == null || value == _directory) return;
    await writeSetting(kDirectoryProperty, value).then((_) {
      _updateDirectory(value);
    });
  }

  final _directoryController = StreamController<bool>.broadcast();
  Stream<bool> get directoryChanged => _directoryController.stream;
  void _updateDirectory(String? value) {
    _directory = value;
    _directoryController.add(true);
  }

  Set<Audio>? _audios;
  Set<Audio>? get audios => _audios;
  set audios(Set<Audio>? value) {
    _updateAudios(value);
  }

  final _audiosController = StreamController<bool>.broadcast();
  Stream<bool> get audiosChanged => _audiosController.stream;
  void _updateAudios(Set<Audio>? value) {
    _audios = value;
    _audiosController.add(true);
  }

  final _failedImports = <String>[];
  Future<List<String>> init() async {
    _failedImports.clear();
    _directory = await readSetting(kDirectoryProperty);
    _directory ??= getUserDirectory('MUSIC')?.path;

    if (_directory != null) {
      final allFileSystemEntities = Set<FileSystemEntity>.from(
        await _getFlattenedFileSystemEntities(path: directory!),
      );

      final onlyFiles = <FileSystemEntity>[];

      for (var fileSystemEntity in allFileSystemEntities) {
        if (!await FileSystemEntity.isDirectory(fileSystemEntity.path) &&
            _validType(fileSystemEntity.path)) {
          onlyFiles.add(fileSystemEntity);
        }
      }

      audios = {};
      for (var e in onlyFiles) {
        try {
          final metadata = await MetadataGod.readMetadata(file: e.path);

          final audio = Audio(
            path: e.path,
            audioType: AudioType.local,
            artist: metadata.artist ?? '',
            title: metadata.title ?? e.path,
            album: metadata.album == null
                ? ''
                : '${metadata.album} ${metadata.discTotal != null && metadata.discTotal! > 1 ? metadata.discNumber : ''}',
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
        } catch (error) {
          _failedImports.add(e.path);
        }
      }
    }
    _audiosController.add(true);
    _directoryController.add(true);
    return _failedImports;
  }

  bool _validType(String path) => mime(path)?.contains('audio') ?? false;

  Future<List<FileSystemEntity>> _getFlattenedFileSystemEntities({
    required String path,
  }) async {
    return await Directory(path)
        .list(recursive: true, followLinks: false)
        .toList();
  }
}
