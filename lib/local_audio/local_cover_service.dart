import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../common/data/audio.dart';
import '../common/logging.dart';
import '../common/persistence/database.dart';
import '../extensions/media_file_x.dart';
import '../extensions/string_x.dart';
import '../extensions/taget_platform_x.dart';
import '../common/persistence_utils.dart';

@singleton
class LocalCoverService {
  final Database _db;

  LocalCoverService({required Database database}) : _db = database;

  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;

  final _cache = <int, Uint8List?>{};
  int get storeLength => _cache.length;

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    final existing = await _db.select(_db.albumArtTable).get();
    for (final row in existing) {
      _cache[row.album] = row.pictureData;
    }
  }

  Future<Uint8List?> getCover({
    required int albumId,
    required String? path,
  }) async {
    if (path == null) return null;

    // Check memory cache first
    if (_cache.containsKey(albumId)) return _cache[albumId];

    // Check database
    final dbCover = await _getFromDb(albumId);
    if (dbCover != null) {
      _cache[albumId] = dbCover;
      return dbCover;
    }

    final file = File(path);
    if (file.existsSync() && file.isPlayable) {
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
      }

      if (bytesFromMetadata == null) return null;

      _cache[albumId] = bytesFromMetadata;
      await _persistToDb(albumId, bytesFromMetadata);
      _propertiesChangedController.add(true);
      return bytesFromMetadata;
    }
    return null;
  }

  Uint8List? get(int? albumId) => albumId == null ? null : _cache[albumId];

  Future<Uint8List?> _getFromDb(int albumId) async {
    final row = await (_db.select(
      _db.albumArtTable,
    )..where((t) => t.album.equals(albumId))).getSingleOrNull();
    return row?.pictureData;
  }

  Future<void> _persistToDb(int albumId, Uint8List data) async {
    final existing = await (_db.select(
      _db.albumArtTable,
    )..where((t) => t.album.equals(albumId))).getSingleOrNull();

    if (existing == null) {
      await _db
          .into(_db.albumArtTable)
          .insert(
            AlbumArtTableCompanion.insert(
              album: albumId,
              pictureData: data,
              pictureMimeType: 'image/png',
            ),
          );
    } else {
      await (_db.update(_db.albumArtTable)
            ..where((t) => t.album.equals(albumId)))
          .write(AlbumArtTableCompanion(pictureData: Value(data)));
    }
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

  Future<void> dispose() async => _propertiesChangedController.close();

  Future<Uri?> createMediaControlsArtUri({Audio? audio}) async {
    if (audio?.imageUrl != null || audio?.albumArtUrl != null) {
      return Uri.tryParse(audio?.imageUrl ?? audio!.albumArtUrl!);
    } else if (audio?.canHaveLocalCover == true &&
        File(audio!.path!).existsSync()) {
      final maybeData = get(audio.albumDbId);
      if (maybeData != null) {
        final File newFile = await _safeTempCover(maybeData);

        return Uri.file(newFile.path, windows: isWindows);
      } else if (audio.albumDbId != null) {
        final newData = await getCover(
          albumId: audio.albumDbId!,
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
