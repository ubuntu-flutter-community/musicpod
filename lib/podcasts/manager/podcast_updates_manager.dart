import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import '../../common/data/audio.dart';
import '../data/podcast_update_capsule.dart';
import '../service/podcast_service.dart';
import 'episodes_manager.dart';

@Injectable(cache: true)
class PodcastUpdatesManager {
  PodcastUpdatesManager({required PodcastService podcastService}) {
    command = Command.createAsyncWithProgress((capsule, handle) async {
      if (capsule.type == PodcastUpdateType.remove) {
        await podcastService.removePodcastUpdates(
          feedUrls: capsule.feedUrls,
          updateProgress: handle.updateProgress,
        );
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

      for (final feedUrl in updates.keys) {
        await di<EpisodesManager>(param1: feedUrl).command.runAsync();
      }

      return updates;
    }, initialValue: {});
  }

  late final Command<PodcastUpdateCapsule, Map<String, Set<Audio>>> command;
}
