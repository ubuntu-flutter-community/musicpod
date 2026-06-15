import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import 'podcast_service.dart';

@Injectable(cache: true)
class EpisodesManager {
  EpisodesManager({
    @factoryParam required String feedUrl,
    required PodcastService podcastService,
  }) {
    printInfoInDebugMode(
      'Instance created for: $feedUrl',
      tag: '$EpisodesManager',
    );
    command = Command.createAsync(
      (genre) => podcastService.findEpisodes(
        feedUrl: feedUrl,
        tryFromDbOnly: true,
        genre: genre,
      ),
      initialValue: null,
    );
    command.run();
  }

  late final Command<String?, List<Audio>?> command;
}
