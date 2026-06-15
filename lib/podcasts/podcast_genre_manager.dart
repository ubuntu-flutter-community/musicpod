import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'podcast_service.dart';

@Injectable(cache: true)
class PodcastGenreManager {
  PodcastGenreManager({
    @factoryParam required String feedUrl,
    required PodcastService podcastService,
  }) {
    findCommand = Command.createAsyncNoParam(
      () => podcastService.findPodcastGenre(feedUrl),
      initialValue: null,
    );

    updateCommand = Command.createAsyncNoResult(
      (param) => podcastService.addPodcastGenre(
        feedUrl: feedUrl,
        genreName: param.genre,
      ),
    );

    findCommand.run();
  }

  late final Command<void, String?> findCommand;

  late final Command<({String genre}), void> updateCommand;
}
