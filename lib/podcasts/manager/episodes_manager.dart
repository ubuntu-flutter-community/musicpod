import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/data/audio.dart';
import '../../common/logging.dart';
import '../../common/view/audio_filter.dart';
import '../service/podcast_service.dart';

@Injectable(cache: true)
class EpisodesManager {
  EpisodesManager({
    @factoryParam required String feedUrl,
    required PodcastService podcastService,
  }) {
    Logger.i('Instance created for feedUrl: $feedUrl', tag: '$EpisodesManager');

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

  late final Command<
    ({AudioSortOrder? order})?,
    ({List<Audio>? episodes, AudioSortOrder? order})?
  >
  command;
}
