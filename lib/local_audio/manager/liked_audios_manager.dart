import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/page_ids.dart';
import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../data/playlist_action.dart';
import '../service/local_audio_service.dart';
import 'liked_audio_paths_manager.dart';
import 'local_audio_manager.dart';

part 'liked_audios_manager.g.dart';

@Riverpod(keepAlive: true)
class LikedAudiosManager extends _$LikedAudiosManager {
  late final LocalAudioService _service = di<LocalAudioService>();

  @override
  Future<List<Audio>?> build() async {
    await ref.watch(localAudioManagerProvider.future);
    return _service.findLikedAudios();
  }

  Future<void> createOrChangeLikedAudios(PlaylistChange param) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _service.createOrChangeLikedAudios(param);
      ref.invalidate(likedAudioPathsManagerProvider);
      return _service.findLikedAudios();
    });
  }

  Future<void> addLikedAudios(List<Audio> audios) async =>
      createOrChangeLikedAudios(
        PlaylistChange(
          id: PageIDs.likedAudios,
          action: PlaylistAction.addTo,
          audios: audios,
        ),
      );

  Future<void> removeLikedAudios(List<Audio> audios) async =>
      createOrChangeLikedAudios(
        PlaylistChange(
          id: PageIDs.likedAudios,
          action: PlaylistAction.removeFrom,
          audios: audios,
        ),
      );
}
