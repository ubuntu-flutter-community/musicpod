import 'dart:typed_data';

import '../compute_isolate.dart';
import '../persistence_utils.dart';

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
      _value = await computeIsolate(() => readUint8ListMap(kCoverStore)) ?? {};
}

const kCoverStore = 'coverStore.json';
