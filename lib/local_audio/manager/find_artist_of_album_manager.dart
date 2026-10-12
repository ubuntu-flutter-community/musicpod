import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'find_artist_of_album_manager.g.dart';

@riverpod
class FindArtistOfAlbumManager extends _$FindArtistOfAlbumManager {
  @override
  Future<String?> build(int albumId) async {
    await ref.watch(localAudioManagerProvider.future);
    return di<LocalAudioService>().findArtistOfAlbum(albumId);
  }
}
