import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/logging.dart';
import '../../common/util/family.dart';
import '../../extensions/command_x.dart';
import '../service/podcast_service.dart';

@injectable
class PodcastCleanManager {
  PodcastCleanManager._(this._podcastService) {
    Logger.o(tag: '$PodcastCleanManager');
  }

  @factoryMethod
  static PodcastCleanManager create(PodcastService podcastService) => Family.of(
    '$PodcastCleanManager',
    () => PodcastCleanManager._(podcastService),
    shouldDispose: (m) => m.command.safeToDispose,
    onDispose: (m) => m.command.dispose(),
  );

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
