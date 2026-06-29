import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/logging.dart';
import '../service/podcast_service.dart';

@Injectable(cache: true)
class PodcastCleanManager {
  PodcastCleanManager(this._podcastService) {
    Logger.o(tag: '$PodcastCleanManager');
    command.run();
  }

  final PodcastService _podcastService;

  late final Command<void, Set<String>?> command = Command.createAsyncNoParam(
    () async {
      final unsubscribedPodcasts = await _podcastService
          .deleteUnsubscribedPodcastData();

      return Set.from(unsubscribedPodcasts ?? {});
    },
    initialValue: null,
  );
}
