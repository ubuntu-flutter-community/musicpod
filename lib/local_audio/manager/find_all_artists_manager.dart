import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'find_all_artists_manager.g.dart';

@riverpod
class FindAllArtistsManager extends _$FindAllArtistsManager {
  @override
  Future<List<String>?> build() async {
    await ref.watch(localAudioManagerProvider.future);
    return di<LocalAudioService>().findAllArtists();
  }
}
