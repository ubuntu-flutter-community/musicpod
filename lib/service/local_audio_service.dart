import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
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

  Future<List<String>> init() async {
    _directory = await readSetting(kDirectoryProperty);
    _directory ??= getUserDirectory('MUSIC')?.path;

    final token = ServicesBinding.rootIsolateToken!;
    final result = await Isolate.run(() => _init(directory, token));

    _audios = result.$2;

    _audiosController.add(true);
    _directoryController.add(true);

    return result.$1;
  }
}

FutureOr<(List<String>, Set<Audio>?)> _init(
  String? directory,
  RootIsolateToken isolateToken,
) async {
  Set<Audio>? newAudios;
  List<String> failedImports = [];

  BackgroundIsolateBinaryMessenger.ensureInitialized(isolateToken);

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
      if (e is File) {
        try {
          final metadata = await MetadataRetriever.fromFile(e);
          final audio = _createAudio(e, metadata);

          newAudios.add(audio);
        } catch (error) {
          failedImports.add(e.path);
        }
      }
    }
  }

  return (failedImports, newAudios);
}

Audio _createAudio(File file, Metadata metadata) {
  return Audio(
    path: file.path,
    audioType: AudioType.local,
    artist: metadata.authorName ??
        metadata.albumArtistName ??
        metadata.trackArtistNames?.join(', ') ??
        '',
    title: metadata.trackName ?? file.path,
    album: metadata.albumName == null
        ? ''
        : '${metadata.albumName} ${metadata.discNumber ?? ''}',
    albumArtist: metadata.albumArtistName,
    discNumber: metadata.discNumber,
    discTotal: metadata.discNumber,
    durationMs: metadata.trackDuration,
    fileSize: file.lengthSync(),
    genre: metadata.genre,
    pictureData: metadata.albumArt,
    pictureMimeType: null,
    trackNumber: metadata.trackNumber,
    year: metadata.year,
  );
}

bool _validType(String path) => mime(path)?.contains('audio') ?? false;

Future<List<FileSystemEntity>> _getFlattenedFileSystemEntities({
  required String path,
}) async {
  return await Directory(path)
      .list(recursive: true, followLinks: false)
      .toList();
}
