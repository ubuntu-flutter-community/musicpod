import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import '../../common/logging.dart';
import '../data/podcast_toggle_capsule.dart';
import 'podcast_manager.dart';

@Injectable(cache: true)
class SubscribedPodcastsManager {
  SubscribedPodcastsManager({required PodcastManager podcastManager}) {
    Logger.i('Instance created', tag: '$SubscribedPodcastsManager');
    command = Command.createAsync((param) async {
      if (param?.feedUrl != null) {
        await podcastManager.togglePodcastSubscription(feedUrl: param!.feedUrl);
      }

      return podcastManager.getSubscribedPodcasts();
    }, initialValue: {});

    command.run();

    podcastManager.wipeCommand.listen((_, _) {
      command.value = {};
    });
  }

  late final Command<PodcastToggleCapsule?, Set<String>> command;
}
