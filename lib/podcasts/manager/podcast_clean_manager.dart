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

  late final Command<({Set<String> deleteMeUrls})?, Set<String>?> command =
      Command.createAsync((param) async {
        final unsubbedFeedUrls = await _podcastService
            .deleteOrphanPodcastData();

        Set<String>? deleteMeUrls;
        if (param?.deleteMeUrls != null) {
          deleteMeUrls = await _podcastService.deletePodcastAndFriends(
            deleteMeUrls: param!.deleteMeUrls,
          );
        }

        return Set.from(unsubbedFeedUrls)..addAll(deleteMeUrls ?? {});
      }, initialValue: null);
}
