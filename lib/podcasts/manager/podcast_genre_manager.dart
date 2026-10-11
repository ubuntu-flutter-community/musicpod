import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/podcast_service.dart';

part 'podcast_genre_manager.g.dart';

@riverpod
class PodcastGenreManager extends _$PodcastGenreManager {
  late final PodcastService _podcastService = di<PodcastService>();

  @override
  Future<String?> build(String feedUrl) =>
      _podcastService.findPodcastGenre(feedUrl);

  Future<void> updateGenre(String genre) async {
    await _podcastService.addPodcastGenre(
      feedUrl: feedUrl,
      genreName: genre,
    );
    state = AsyncData(genre);
  }
}
