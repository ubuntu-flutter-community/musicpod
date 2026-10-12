import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'find_album_manager.g.dart';

@riverpod
class FindAlbumManager extends _$FindAlbumManager {
  @override
  Future<List<Audio>?> build(int albumId) async {
    await ref.watch(localAudioManagerProvider.future);
    return di<LocalAudioService>().findAlbum(albumId);
  }
}
