import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/foundation.dart';

import '../../data.dart';
import '../../utils.dart';
import '../settings/settings_service.dart';

class LocalAudioService {
  final SettingsService _settingsService;

  Set<Audio>? _audios;
  LocalAudioService({required SettingsService settingsService})
      : _settingsService = settingsService;
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

  Future<List<String>> init({@visibleForTesting String? testDir}) async {
    final result = await compute(_init, testDir ?? _settingsService.directory);

    _audios = result.$2;

    _audiosController.add(true);

    return result.$1;
  }

  Future<void> dispose() async {
    await _audiosController.close();
  }
}

FutureOr<(List<String>, Set<Audio>?)> _init(String? directory) async {
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
        final metadata = await readMetadata(File(e.path), getImage: true);
        final audio = Audio.fromMetadata(path: e.path, data: metadata);

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
