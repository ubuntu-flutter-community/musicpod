import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import '../data/podcast_toggle_capsule.dart';
import 'podcast_manager.dart';

@lazySingleton
class SubscribedPodcastsManager {
  SubscribedPodcastsManager({required PodcastManager podcastManager}) {
    command = Command.createAsync((param) async {
      if (param?.feedUrl != null) {
        await podcastManager.togglePodcastSubscription(feedUrl: param!.feedUrl);
      }

      return podcastManager.getSubscribedPodcasts();
    }, initialValue: {});

    command.run();

    podcastManager.wipeCommand.listen((_, sub) {
      command.run();
      sub.cancel();
    });
  }

  late final Command<PodcastToggleCapsule?, Set<String>> command;
}
