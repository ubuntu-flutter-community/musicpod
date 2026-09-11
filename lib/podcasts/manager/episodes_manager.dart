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
  static const int pageSize = 25;

  ListenableSubscription? updatesOnlySubscription;
  ListenableSubscription? downloadsOnlySubscription;
  ListenableSubscription? downloadCommandsSubscription;
  ListenableSubscription? searchQuerySubscription;
  ListenableSubscription? filterSubscription;

  List<Audio> _allEpisodes = [];

  final displayedCount = SafeValueNotifier<int>(pageSize);

  bool get hasMore => displayedCount.value < _allEpisodes.length;
  int get totalCount => _allEpisodes.length;
  List<Audio> get allFilteredEpisodes => List.unmodifiable(_allEpisodes);

  void loadMore() {
    if (!hasMore) return;
    displayedCount.value =
        (displayedCount.value + pageSize).clamp(0, _allEpisodes.length);
    if (command.value != null) {
      command.value = (
        episodes: _allEpisodes.take(displayedCount.value).toList(),
        order: command.value!.order,
      );
    }
  }

  void _resetPaging() {
    displayedCount.value = pageSize;
  }

  EpisodesManager._({
    required String feedUrl,
    required PodcastManager podcastManager,
    required DownloadManager downloadsManager,
    required PlayerManager playerManager,
  }) {
    updatesOnlySubscription ??= podcastManager.updatesOnly.listen((_, _) {
      _resetPaging();
      command.run();
    });
    downloadsOnlySubscription ??= podcastManager.downloadsOnly.listen((_, _) {
      _resetPaging();
      command.run();
    });
    downloadCommandsSubscription ??= downloadsManager.downloadCommands
        .select((v) => v.entries.any((e) => e.key.feedUrl == feedUrl))
        .listen((_, _) => command.run());
    searchQuerySubscription ??= searchQuery.listen((_, _) {
      _resetPaging();
      command.run();
    });
    filterSubscription ??= filter.listen((_, _) {
      _resetPaging();
      command.run();
    });

    command = Command.createAsync(
      (param) async {
        if (param?.order != null) {
          _resetPaging();
        }

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

        _allEpisodes = episodes;
        final currentCount = displayedCount.value.clamp(0, _allEpisodes.length);
        final visible = _allEpisodes
            .take(
              currentCount == 0 && _allEpisodes.isNotEmpty
                  ? pageSize
                  : currentCount,
            )
            .toList();

        final theOrder =
            (await podcastManager.ascendingPodcasts).contains(feedUrl)
                ? AudioSortOrder.ascending
                : AudioSortOrder.descending;

        return (
          episodes: visible,
          order: theOrder,
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
    shouldDispose: (instance) => instance.command.safeToDispose,
    onDispose: (instance) {
      instance.command.dispose();
      instance.updatesOnlySubscription?.cancel();
      instance.downloadsOnlySubscription?.cancel();
      instance.downloadCommandsSubscription?.cancel();
      instance.searchQuerySubscription?.cancel();
      instance.filterSubscription?.cancel();
      instance.displayedCount.dispose();
      instance.showSearch.dispose();
      instance.searchQuery.dispose();
      instance.filter.dispose();
    },
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
