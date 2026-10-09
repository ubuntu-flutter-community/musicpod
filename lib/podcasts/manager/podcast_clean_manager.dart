import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/logging.dart';
import '../../common/util/family.dart';
import '../service/podcast_service.dart';

@Injectable(cache: true)
class PodcastCleanManager {
  PodcastCleanManager(this._podcastService) {
    Logger.o(tag: '$PodcastCleanManager');
  }

  final PodcastService _podcastService;

  late final Command<({bool reclaimDiskSpace}), Set<String>?> command =
      Command.createAsync((options) async {
        final unsubscribedPodcasts = await _podcastService
            .deleteUnsubscribedPodcastData();

        if (unsubscribedPodcasts != null) {
          for (final feedUrl in unsubscribedPodcasts) {
            Family.disposeById(feedUrl);
          }
        }

        if (options.reclaimDiskSpace) {
          await _podcastService.reclaimDiskSpace();
        }

        return Set.from(unsubscribedPodcasts ?? {});
      }, initialValue: null);
}
