import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import '../extensions/media_file_x.dart';
import '../extensions/string_x.dart';
import '../extensions/taget_platform_x.dart';
import '../persistence_utils.dart';

class LocalCoverService {
  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;

  final _store = <String, Uint8List?>{};
  int get storeLength => _store.length;

  Future<Uint8List?> getCover({
    required String albumId,
    required String path,
    Function()? onError,
  }) async {
    final file = File(path);
    if (file.existsSync() && file.isPlayable && albumId.isNotEmpty == true) {
      Uint8List? bytesFromMetadata;

      try {
        final metadata = readMetadata(file, getImage: true);
        bytesFromMetadata = metadata.pictures
            .firstWhereOrNull(
              (e) =>
                  (e.bytes.isNotEmpty &&
                      e.pictureType == PictureType.coverFront) ||
                  e.bytes.isNotEmpty,
            )
            ?.bytes;

        if (bytesFromMetadata == null) {
          final maybeImageInFolder = _getImageInFolder(file);
          if (maybeImageInFolder != null) {
            bytesFromMetadata = File(maybeImageInFolder).readAsBytesSync();
          }
        }
      } on Exception catch (e) {
        printMessageInDebugMode(e);
        onError?.call();
      }

      if (bytesFromMetadata == null) return null;

      final cover = _put(albumId: albumId, data: bytesFromMetadata);
      if (cover != null) {
        _propertiesChangedController.add(true);
      }
      return cover;
    }
    return null;
  }

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

  Uint8List? _put({required String albumId, Uint8List? data}) {
    return _store.containsKey(albumId)
        ? _store.update(albumId, (value) => data)
        : _store.putIfAbsent(albumId, () => data);
  }

  Uint8List? get(String? albumId) => albumId == null ? null : _store[albumId];

  Future<void> dispose() async => _propertiesChangedController.close();

  Future<Uri?> createMediaControlsArtUri({Audio? audio}) async {
    if (audio?.imageUrl != null || audio?.albumArtUrl != null) {
      return Uri.tryParse(audio?.imageUrl ?? audio!.albumArtUrl!);
    } else if (audio?.canHaveLocalCover == true &&
        File(audio!.path!).existsSync()) {
      final maybeData = get(audio.albumId);
      if (maybeData != null) {
        final File newFile = await _safeTempCover(maybeData);

        return Uri.file(newFile.path, windows: isWindows);
      } else {
        final newData = await getCover(
          albumId: audio.albumId!,
          path: audio.path!,
        );
        if (newData != null) {
          final File newFile = await _safeTempCover(newData);

          return Uri.file(newFile.path, windows: isWindows);
        }
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
