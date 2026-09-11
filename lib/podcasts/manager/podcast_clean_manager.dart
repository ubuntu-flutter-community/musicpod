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
    command.run();
  }

  @factoryMethod
  static PodcastCleanManager create(PodcastService podcastService) => Family.of(
    '$PodcastCleanManager',
    () => PodcastCleanManager._(podcastService),
    shouldDispose: (m) => m.command.safeToDispose,
    onDispose: (m) => m.command.dispose(),
  );

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
