import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/local_cover_service.dart';

part 'local_cover_manager.g.dart';

@riverpod
class LocalCoverManager extends _$LocalCoverManager {
  @override
  Future<Uint8List?> build(int albumId) =>
      di<LocalCoverService>().getCover(albumId: albumId);
}
