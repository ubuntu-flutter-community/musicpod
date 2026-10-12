import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'find_album_id_manager.g.dart';

@riverpod
class FindAlbumIdManager extends _$FindAlbumIdManager {
  @override
  Future<int?> build({required String artist, required String album}) async {
    await ref.watch(localAudioManagerProvider.future);
    return di<LocalAudioService>().findAlbumIdForArtistAndAlbum(
      artist: artist,
      album: album,
    );
  }
}
