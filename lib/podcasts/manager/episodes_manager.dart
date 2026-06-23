import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/data/audio.dart';
import '../../common/logging.dart';
import '../../common/view/audio_filter.dart';
import '../podcast_service.dart';

@Injectable(cache: true)
class EpisodesManager {
  EpisodesManager({
    @factoryParam required String feedUrl,
    required PodcastService podcastService,
  }) {
    Logger.i('Instance created for feedUrl: $feedUrl', tag: '$EpisodesManager');
    reorderPodcastCommand = Command.createAsync((param) async {
      await podcastService.reorderPodcast(
        feedUrl: param.feedUrl,
        ascending: param.ascending,
      );

      return (
        ascendingPodcasts: await podcastService.ascendingPodcasts,
        descendingPodcasts: await podcastService.descendingPodcasts,
      );
    }, initialValue: null);

    command = Command.createAsync((param) async {
      final episodes = await podcastService.findEpisodes(
        feedUrl: feedUrl,
        tryFromDbOnly: true,
      );
      sortListByAudioFilter(
        audioFilter: AudioFilter.year,
        audios: episodes,
        descending: !(param?.ascending ?? true),
      );

      return episodes;
    }, initialValue: null);

    reorderPodcastCommand.listen((results, sub) {
      if (results == null) return;
      if (results.ascendingPodcasts.contains(feedUrl)) {
        command.run((ascending: true));
      } else if (results.descendingPodcasts.contains(feedUrl)) {
        command.run((ascending: false));
      }
    });

    command.run();
  }

  late final Command<
    ({
      // TODO: move filtering to dao/service
      // bool withDownloads, bool hasUpdates,
      bool ascending,
    })?,
    List<Audio>?
  >
  command;

  late final Command<
    ({String feedUrl, bool ascending}),
    ({Set<String> ascendingPodcasts, Set<String> descendingPodcasts})?
  >
  reorderPodcastCommand;
}
