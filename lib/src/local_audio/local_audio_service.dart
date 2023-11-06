import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:mime_type/mime_type.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/utils.dart';

import '../../data.dart';

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

  Future<List<String>> init() async {
    _directory = await readSetting(kDirectoryProperty);
    _directory ??= await getMusicDir();

    final result = await compute(_init, directory);

    _audios = result.$2;

    _audiosController.add(true);
    _directoryController.add(true);

    return result.$1;
  }

  Future<void> dispose() async {
    await _audiosController.close();
    await _directoryController.close();
  }
}

FutureOr<(List<String>, Set<Audio>?)> _init(String? directory) async {
  MetadataGod.initialize();

  Set<Audio>? newAudios;
  List<String> failedImports = [];

  if (directory != null) {
    newAudios = {};

    final allFileSystemEntities = Set<FileSystemEntity>.from(
      await _getFlattenedFileSystemEntities(path: directory),
    );

    final onlyFiles = <FileSystemEntity>[];

    for (var fileSystemEntity in allFileSystemEntities) {
      if (!await FileSystemEntity.isDirectory(fileSystemEntity.path) &&
          _validType(fileSystemEntity.path)) {
        onlyFiles.add(fileSystemEntity);
      }
    }
    for (var e in onlyFiles) {
      try {
        final metadata = await MetadataGod.readMetadata(file: e.path);
        final audio = createLocalAudio(
          e.path,
          metadata,
          File(e.path).uri.pathSegments.last,
        );

        newAudios.add(audio);
      } catch (error) {
        failedImports.add(e.path);
      }
    }
  }

  return (failedImports, newAudios);
}

bool _validType(String path) => mime(path)?.contains('audio') ?? false;

Future<List<FileSystemEntity>> _getFlattenedFileSystemEntities({
  required String path,
}) async {
  return await Directory(path)
      .list(recursive: true, followLinks: false)
      .toList();
}
