import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../data/podcast_genre.dart';
import '../service/podcast_service.dart';

@lazySingleton
class PodcastLoadGenresManager {
  PodcastLoadGenresManager({required PodcastService podcastService}) {
    command = Command.createAsyncNoParam(
      () => podcastService.loadGenres(),
      initialValue: const [],
    );
    command.run();
  }

  late final Command<void, List<PodcastGenre>> command;
}
