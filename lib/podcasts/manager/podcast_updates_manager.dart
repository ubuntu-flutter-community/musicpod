import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import '../data/podcast_update_capsule.dart';
import '../podcast_service.dart';
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
        return podcastService.getPodcastUpdates();
      }

      final updates = await podcastService.checkForUpdates(
        feedUrls: capsule.feedUrls,
        updateProgress: handle.updateProgress,
      );

      for (final feedUrl in updates) {
        await di<EpisodesManager>(param1: feedUrl).command.runAsync();
      }

      return updates;
    }, initialValue: {});
  }

  late final Command<PodcastUpdateCapsule, Set<String>> command;
}
