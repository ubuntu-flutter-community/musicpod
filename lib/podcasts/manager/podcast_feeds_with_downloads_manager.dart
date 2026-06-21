import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'podcast_manager.dart';

@Injectable(cache: true)
class PodcastFeedsWithDownloadsManager {
  PodcastFeedsWithDownloadsManager({required PodcastManager podcastManager}) {
    command = Command.createAsyncNoParam(() async {
      if (podcastManager.feedsWithDownloads.isEmpty) {
        await podcastManager.loadDownloads();
      }

      return podcastManager.feedsWithDownloads;
    }, initialValue: podcastManager.feedsWithDownloads);

    podcastManager.wipeCommand.listen((_, sub) {
      command.run();
      sub.cancel();
    });

    command.run();
  }

  late final Command<void, Set<String>> command;
}
