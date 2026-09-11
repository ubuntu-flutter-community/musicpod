import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import '../../common/data/audio.dart';
import '../../common/util/family.dart';
import '../../extensions/command_x.dart';
import '../data/podcast_update_capsule.dart';
import '../service/podcast_service.dart';
import 'episodes_manager.dart';
import 'podcast_updated_feeds_manager.dart';

@injectable
class PodcastUpdatesManager {
  PodcastUpdatesManager._({
    required PodcastService podcastService,
    required PodcastUpdatedFeedsManager feedsManager,
  }) {
    command = Command.createAsyncWithProgress((capsule, handle) async {
      if (capsule.type == PodcastUpdateType.remove) {
        await podcastService.removePodcastUpdates(
          feedUrls: capsule.feedUrls,
          updateProgress: handle.updateProgress,
        );

        feedsManager.command.run();

        return podcastService.getPodcastUpdates().then((updates) async {
          final result = <String, Set<Audio>>{};
          for (final feedUrl in updates) {
            result[feedUrl] = {};
          }
          return result;
        });
      }

      final updates = await podcastService.checkForUpdates(
        feedUrls: capsule.feedUrls,
        updateProgress: handle.updateProgress,
      );

      feedsManager.command.run();

      for (final feedUrl in updates.keys) {
        await Family.get<EpisodesManager>(feedUrl)?.command.runAsync();
      }

      return updates;
    }, initialValue: {});
  }

  @factoryMethod
  static PodcastUpdatesManager create({
    required PodcastService podcastService,
    required PodcastUpdatedFeedsManager feedsManager,
  }) => Family.of(
    '$PodcastUpdatesManager',
    () => PodcastUpdatesManager._(
      podcastService: podcastService,
      feedsManager: feedsManager,
    ),
    shouldDispose: (t) => t.command.safeToDispose,
    autoDisposeAfter: const Duration(minutes: 1),
    onDispose: (t) => t.command.dispose(),
  );

  /// Holds the Map of new episode Audios and handles update check and removal.
  late final Command<PodcastUpdateCapsule, Map<String, Set<Audio>>> command;

  static void dispose() => Family.disposeAll<PodcastUpdatesManager>();
}
