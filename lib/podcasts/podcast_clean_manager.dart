import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/logging.dart';
import 'podcast_service.dart';

@Injectable(cache: true)
class PodcastCleanManager {
  PodcastCleanManager(this._podcastService) {
    printMessageInDebugMode('PodcastCleanManager created');
    command.run();
  }

  final PodcastService _podcastService;

  late final Command<void, Set<String>?> command = Command.createAsyncNoParam(
    () async {
      final unsubbedFeedUrls = await _podcastService.deleteOrphanEpisodes();

      return unsubbedFeedUrls;
    },
    initialValue: null,
  );
}
