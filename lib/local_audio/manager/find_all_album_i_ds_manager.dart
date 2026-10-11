import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'find_all_album_i_ds_manager.g.dart';

@riverpod
class FindAllAlbumIDsManager extends _$FindAllAlbumIDsManager {
  @override
  Future<List<int>?> build() async {
    await ref.watch(localAudioManagerProvider.future);
    return di<LocalAudioService>().findAllAlbumIDs();
  }
}
