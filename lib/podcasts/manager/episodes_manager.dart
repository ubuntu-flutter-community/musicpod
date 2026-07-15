import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common/data/audio.dart';
import '../../common/util/family.dart';
import '../../common/view/audio_filter.dart';
import '../../extensions/command_x.dart';
import '../../player/manager/player_manager.dart';
import '../data/podcast_episode_filter.dart';
import 'download_manager.dart';
import 'podcast_manager.dart';
import 'podcast_short_info_manager.dart';

@injectable
class EpisodesManager {
  EpisodesManager._({
    required String feedUrl,
    required PodcastManager podcastManager,
    required DownloadManager downloadsManager,
    required PlayerManager playerManager,
  }) {
    podcastManager.updatesOnly.listen((_, _) => command.run());
    podcastManager.downloadsOnly.listen((_, _) => command.run());
    downloadsManager.downloadCommands
        .select((v) => v.entries.any((e) => e.key.feedUrl == feedUrl))
        .listen((_, _) => command.run());
    searchQuery.listen((_, _) => command.run());
    filter.listen((_, _) => command.run());

    command = Command.createAsync(
      (param) async {
        final searchQuery = this.searchQuery.value;
        final filter = this.filter.value;
        final hideCompletedEpisodes = podcastManager.updatesOnly.value;
        final showDownloadsOnly = podcastManager.downloadsOnly.value;
        final episodes =
            (await podcastManager.findEpisodes(
                  feedUrl: feedUrl,
                  tryFromDbOnly: true,
                  order: param?.order,
                ))
                .where((a) => a.title != null && a.episodeDescription != null)
                .where(
                  (a) => (searchQuery == null || searchQuery.trim().isEmpty)
                      ? true
                      : switch (filter) {
                          PodcastEpisodeFilter.title =>
                            a.title!.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            ),
                          PodcastEpisodeFilter.description =>
                            a.episodeDescription!.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            ),
                        },
                )
                .where((audio) {
                  if (!hideCompletedEpisodes) return true;
                  if (audio.url == null) return false;

                  return audio.durationMs != null &&
                      playerManager.lastPositions?[audio.url]?.inMilliseconds !=
                          audio.durationMs?.toInt();
                })
                .where((audio) {
                  if (!showDownloadsOnly) return true;

                  return downloadsManager.hasDownload(audio);
                })
                .toList();

        di<PodcastShortInfoManager>(param1: feedUrl).command.runRestricted();

        return (
          episodes: episodes,
          order: (await podcastManager.ascendingPodcasts).contains(feedUrl)
              ? AudioSortOrder.ascending
              : AudioSortOrder.descending,
        );
      },
      initialValue: null,
      includeLastResultInCommandResults: true,
    );

    command.run();
  }

  @factoryMethod
  static EpisodesManager create({
    @factoryParam required String feedUrl,
    required PodcastManager podcastManager,
    required DownloadManager downloadsManager,
    required PlayerManager playerManager,
  }) => Family.of(
    feedUrl,
    () => EpisodesManager._(
      feedUrl: feedUrl,
      podcastManager: podcastManager,
      downloadsManager: downloadsManager,
      playerManager: playerManager,
    ),
    shouldDispose: (instance) => instance.command.listenerCount == 0,
    onDispose: (instance) => instance.command.dispose(),
  );

  late final Command<
    ({AudioSortOrder? order})?,
    ({List<Audio>? episodes, AudioSortOrder? order})?
  >
  command;

  final showSearch = SafeValueNotifier(false);

  void toggleShowSearch() => showSearch.value = !showSearch.value;

  final searchQuery = SafeValueNotifier<String?>(null);
  void setSearchQuery(String value) => searchQuery.value = value;

  final filter = SafeValueNotifier<PodcastEpisodeFilter>(
    PodcastEpisodeFilter.title,
  );
  void setFilter() => filter.value = switch (filter.value) {
    PodcastEpisodeFilter.title => PodcastEpisodeFilter.description,
    PodcastEpisodeFilter.description => PodcastEpisodeFilter.title,
  };
}
