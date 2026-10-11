import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'pinned_album_ids_manager.g.dart';

@Riverpod(keepAlive: true)
class PinnedAlbumIDsManager extends _$PinnedAlbumIDsManager {
  late final LocalAudioService _service = di<LocalAudioService>();

  @override
  Future<List<int>> build() async {
    await ref.watch(localAudioManagerProvider.future);
    return _service.findPinnedAlbumIDs();
  }

  Future<void> togglePinAlbum(int? id) async => state = await AsyncValue.guard(
    () => _service.togglePinAlbum(id),
  );
}
