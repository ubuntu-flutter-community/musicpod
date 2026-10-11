import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'find_all_genres_manager.g.dart';

@riverpod
class FindAllGenresManager extends _$FindAllGenresManager {
  @override
  Future<List<String>?> build() async {
    await ref.watch(localAudioManagerProvider.future);
    return di<LocalAudioService>().findAllGenres();
  }
}
