import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'album_ids_of_genre_manager.g.dart';

@riverpod
class AlbumIDsOfGenreManager extends _$AlbumIDsOfGenreManager {
  @override
  Future<List<int>?> build(String genre) async {
    await ref.watch(localAudioManagerProvider.future);
    return di<LocalAudioService>().findAlbumIDsOfGenre(genre);
  }
}
