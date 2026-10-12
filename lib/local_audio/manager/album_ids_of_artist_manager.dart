import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'album_ids_of_artist_manager.g.dart';

@riverpod
class AlbumIDsOfArtistManager extends _$AlbumIDsOfArtistManager {
  @override
  Future<List<int>?> build(String artist) async {
    await ref.watch(localAudioManagerProvider.future);
    return di<LocalAudioService>().findAlbumIDsOfArtist(artist);
  }
}
