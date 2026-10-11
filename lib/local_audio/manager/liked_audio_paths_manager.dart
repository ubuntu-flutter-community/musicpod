import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/page_ids.dart';
import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../data/playlist_action.dart';
import '../service/local_audio_service.dart';
import 'liked_audios_manager.dart';
import 'local_audio_manager.dart';

part 'liked_audio_paths_manager.g.dart';

@Riverpod(keepAlive: true)
class LikedAudioPathsManager extends _$LikedAudioPathsManager {
  late final LocalAudioService _service = di<LocalAudioService>();

  @override
  Future<Set<String>> build() async {
    await ref.watch(localAudioManagerProvider.future);
    return _service.findLikedAudioPaths();
  }

  Future<void> addLikedAudios(List<Audio> audios) async => _update(
    PlaylistChange(
      id: PageIDs.likedAudios,
      action: PlaylistAction.addTo,
      audios: audios,
    ),
  );

  Future<void> removeLikedAudios(List<Audio> audios) async => _update(
    PlaylistChange(
      id: PageIDs.likedAudios,
      action: PlaylistAction.removeFrom,
      audios: audios,
    ),
  );

  Future<void> _update(PlaylistChange change) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _service.createOrChangeLikedAudios(change);
      ref.invalidate(likedAudiosManagerProvider);
      return _service.findLikedAudioPaths();
    });
  }
}
