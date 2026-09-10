import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/util/family.dart';
import 'podcast_manager.dart';

@injectable
class PodcastFeedsWithDownloadsManager {
  PodcastFeedsWithDownloadsManager._({required PodcastManager podcastManager}) {
    command = Command.createAsyncNoParam(() async {
      if (podcastManager.feedsWithDownloads.isEmpty) {
        await podcastManager.loadDownloads();
      }

      return podcastManager.feedsWithDownloads;
    }, initialValue: podcastManager.feedsWithDownloads);

    command.run();
  }

  @factoryMethod
  static PodcastFeedsWithDownloadsManager create({
    required PodcastManager podcastManager,
  }) => Family.of(
    '$PodcastFeedsWithDownloadsManager',
    () => PodcastFeedsWithDownloadsManager._(podcastManager: podcastManager),
    shouldDispose: (m) => m.command.listenerCount == 0,
    onDispose: (m) => m.command.dispose(),
  );

  late final Command<void, Set<String>> command;
}
