import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';

import '../compute_isolate.dart';
import '../constants.dart';
import '../persistence_utils.dart';

Future<Uint8List?> getCover({
  required String albumId,
  required String path,
}) async {
  if (albumId.isNotEmpty == true) {
    final metadata = await readMetadata(File(path), getImage: true);
    return CoverStore().put(
      albumId: albumId,
      data:
          metadata.pictures.firstWhereOrNull((e) => e.bytes.isNotEmpty)?.bytes,
    );
  }

  return null;
}

class CoverStore {
  static final CoverStore _instance = CoverStore._internal();
  factory CoverStore() => _instance;
  CoverStore._internal();

  var _value = <String, Uint8List?>{};

  Uint8List? put({required String albumId, Uint8List? data}) {
    return _value.containsKey(albumId)
        ? _value.update(albumId, (value) => data)
        : _value.putIfAbsent(albumId, () => data);
  }

  Uint8List? get(String? albumId) => albumId == null ? null : _value[albumId];

  Future<void> write() async => writeUint8ListMap(_value, kCoverStore);

  Future<void> read() async =>
      _value = await computeIsolate(() => readUint8ListMap(kCoverStore)) ?? [];
}
