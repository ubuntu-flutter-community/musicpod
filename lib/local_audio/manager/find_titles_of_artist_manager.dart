import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../common/view/audio_filter.dart';
import '../../dependencies.dart';
import '../service/local_audio_service.dart';
import 'local_audio_manager.dart';

part 'find_titles_of_artist_manager.g.dart';

@riverpod
class FindTitlesOfArtistManager extends _$FindTitlesOfArtistManager {
  @override
  Future<List<Audio>?> build(
    String artist, [
    AudioFilter filter = AudioFilter.album,
  ]) async {
    await ref.watch(localAudioManagerProvider.future);
    return di<LocalAudioService>().findTitlesOfArtist(artist, filter);
  }
}
