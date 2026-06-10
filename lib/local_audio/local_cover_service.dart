import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../common/data/audio.dart';
import '../common/logging.dart';
import '../common/persistence_utils.dart';
import '../extensions/media_file_x.dart';
import '../extensions/string_x.dart';
import '../extensions/taget_platform_x.dart';
import 'persistence/local_audio_dao.dart';

@lazySingleton
class LocalCoverService {
  final LocalAudioDao _dao;

  LocalCoverService({required LocalAudioDao dao}) : _dao = dao;

  Future<Uint8List?> getCover({required int albumId}) async {
    // Check database
    final dbCover = await getFromDb(albumId);
    if (dbCover != null) {
      return dbCover;
    }

    final path = await _dao.findPathOfFirstTrackInAlbum(albumId);
    if (path == null) return null;

    final file = File(path);
    if (file.existsSync() && file.isPlayable) {
      Uint8List? bytesFromMetadata;

      try {
        bytesFromMetadata = await compute(_readCoverFromFile, path);

        if (bytesFromMetadata == null) {
          final maybeImageInFolder = _getImageInFolder(file);
          if (maybeImageInFolder != null) {
            bytesFromMetadata = File(maybeImageInFolder).readAsBytesSync();
          }
        }
      } on Exception catch (e, s) {
        printErrorInDebugMode(e, trace: s, tag: '$LocalCoverService');
      }

      if (bytesFromMetadata == null) return null;

      await _dao.addAlbumCover(albumId, bytesFromMetadata);
      return bytesFromMetadata;
    }
    return null;
  }

  Future<Uint8List?> getFromDb(int albumId) => _dao.getAlbumCover(albumId);

  String? _getImageInFolder(File file) =>
      _commonCoverInFolderNames.firstWhereOrNull(
        (e) => _maybeImageInFolderExists(file: file, suffix: e),
      ) ??
      _commonCoverInFolderNames
          .map((e) => e.capitalized)
          .toList()
          .firstWhereOrNull(
            (e) => _maybeImageInFolderExists(file: file, suffix: e),
          );

  static const _commonCoverInFolderNames = [
    'front.jpg',
    'front.png',
    'front.jpeg',
    'cover.jpg',
    'cover.png',
    'cover.jpeg',
    'album.jpg',
    'album.png',
    'album.jpeg',
    'back.jpg',
    'back.png',
    'back.jpeg',
  ];

  bool _maybeImageInFolderExists({
    required File file,
    required String suffix,
  }) => Directory(p.join(file.parent.path, suffix)).existsSync();

  Future<Uri?> createMediaControlsArtUri({Audio? audio}) async {
    if (audio?.imageUrl != null || audio?.albumArtUrl != null) {
      final uri = Uri.tryParse(audio?.imageUrl ?? audio!.albumArtUrl!);
      if (uri != null && uri.hasScheme && uri.host.isNotEmpty) return uri;
    } else if (audio?.canHaveLocalCover == true &&
        File(audio!.path!).existsSync()) {
      final newData = await getCover(albumId: audio.albumDbId!);
      if (newData != null) {
        final File newFile = await _safeTempCover(newData);

        return Uri.file(newFile.path, windows: isWindows);
      }
    }

    return null;
  }

  Future<File> _safeTempCover(Uint8List maybeData) async {
    final workingDir = await getWorkingDir();

    final imagesDir = p.join(workingDir, 'images');

    if (Directory(imagesDir).existsSync()) {
      Directory(imagesDir).deleteSync(recursive: true);
    }
    Directory(imagesDir).createSync();
    final now = DateTime.now().toUtc().toString().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final file = File(p.join(imagesDir, '$now.png'));
    final newFile = await file.writeAsBytes(maybeData);
    return newFile;
  }
}

Uint8List? _readCoverFromFile(String path) {
  final metadata = readMetadata(File(path), getImage: true);
  return metadata.pictures
      .firstWhereOrNull(
        (e) =>
            (e.bytes.isNotEmpty && e.pictureType == PictureType.coverFront) ||
            e.bytes.isNotEmpty,
      )
      ?.bytes;
}
