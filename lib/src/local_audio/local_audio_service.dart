import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:metadata_god/metadata_god.dart';

import '../../data.dart';
import '../../utils.dart';
import '../settings/settings_service.dart';

class LocalAudioService {
  final SettingsService settingsService;

  Set<Audio>? _audios;
  LocalAudioService({
    required this.settingsService,
  });

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

  Future<List<String>> init({
    @visibleForTesting String? testDir,
  }) async {
    String? dir;
    if (testDir != null) {
      dir = testDir;
    } else {
      dir = settingsService.directory.value;
      dir ??= await getMusicDir();
    }

    final result = await compute(_init, dir);

    _audios = result.$2;

    _audiosController.add(true);

    return result.$1;
  }

  Future<void> dispose() async {
    await _audiosController.close();
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
