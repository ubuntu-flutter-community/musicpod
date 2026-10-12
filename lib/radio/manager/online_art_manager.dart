import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/online_art_service.dart';

part 'online_art_manager.g.dart';

@riverpod
class OnlineArtManager extends _$OnlineArtManager {
  @override
  Future<String?> build(String? icyTitle) async =>
      (icyTitle == null || icyTitle.isEmpty)
      ? null
      : di<OnlineArtService>().fetchAlbumArt(icyTitle: icyTitle);
}
