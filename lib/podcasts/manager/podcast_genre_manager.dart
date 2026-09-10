import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import '../service/podcast_service.dart';

@injectable
class PodcastGenreManager {
  PodcastGenreManager._({
    required String feedUrl,
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

  @factoryMethod
  static PodcastGenreManager create({
    @factoryParam required String feedUrl,
    required PodcastService podcastService,
  }) => Family.of(
    feedUrl,
    () =>
        PodcastGenreManager._(feedUrl: feedUrl, podcastService: podcastService),
    shouldDispose: (m) =>
        m.findCommand.listenerCount == 0 && m.updateCommand.listenerCount == 0,
    onDispose: (m) {
      m.findCommand.dispose();
      m.updateCommand.dispose();
    },
  );

  late final Command<void, String?> findCommand;

  late final Command<({String genre}), void> updateCommand;
}
