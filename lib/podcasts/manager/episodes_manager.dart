import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/data/audio.dart';
import '../../common/logging.dart';
import '../../common/util/keep_alive_registry.dart';
import '../../common/view/audio_filter.dart';
import '../service/podcast_service.dart';

@injectable
class EpisodesManager {
  EpisodesManager._({
    @factoryParam required String feedUrl,
    required PodcastService podcastService,
  }) {
    Logger.o(tag: '$EpisodesManager:$feedUrl');

    command = Command.createAsync((param) async {
      final episodes = await podcastService.findEpisodes(
        feedUrl: feedUrl,
        tryFromDbOnly: true,
        order: param?.order,
      );

      return (
        episodes: episodes,
        order: (await podcastService.ascendingPodcasts).contains(feedUrl)
            ? AudioSortOrder.ascending
            : AudioSortOrder.descending,
      );
    }, initialValue: null);

    command.run();
  }

  @factoryMethod
  static EpisodesManager create({
    @factoryParam required String feedUrl,
    required PodcastService podcastService,
  }) => _registry.getOrRegister(
    id: feedUrl,
    factoryFunction: () =>
        EpisodesManager._(feedUrl: feedUrl, podcastService: podcastService),
  );

  late final Command<
    ({AudioSortOrder? order})?,
    ({List<Audio>? episodes, AudioSortOrder? order})?
  >
  command;

  static final _registry = KeepAliveRegistry<String, EpisodesManager>();
  static void dispose(String feedUrl) => _registry.dispose(feedUrl);
}
