import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/podcast_genre.dart';
import '../service/podcast_service.dart';

part 'podcast_load_genres_manager.g.dart';

@Riverpod(keepAlive: true)
class PodcastLoadGenresManager extends _$PodcastLoadGenresManager {
  late final PodcastService _podcastService = di<PodcastService>();

  @override
  Future<List<PodcastGenre>> build() => _podcastService.loadGenres();

  Future<List<PodcastGenre>> loadGenres({bool force = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _podcastService.loadGenres(force: force),
    );
    return state.value ?? [];
  }
}
