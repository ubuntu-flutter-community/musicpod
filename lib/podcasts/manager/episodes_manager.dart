import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../common/view/audio_filter.dart';
import '../../dependencies.dart';
import '../../player/manager/audio_progress_manager.dart';
import '../data/podcast_episode_filter.dart';
import '../service/podcast_service.dart';
import 'download_manager.dart';
import 'podcast_collection_filter_manager.dart';

part 'episodes_manager.g.dart';

class EpisodesState {
  final List<Audio> allEpisodes;
  final List<Audio> episodes;
  final int displayedCount;
  final int totalCount;
  final bool hasMore;
  final AudioSortOrder order;
  final bool showSearch;
  final String? searchQuery;
  final PodcastEpisodeFilter filter;

  const EpisodesState({
    required this.allEpisodes,
    required this.episodes,
    required this.displayedCount,
    required this.totalCount,
    required this.hasMore,
    required this.order,
    this.showSearch = false,
    this.searchQuery,
    this.filter = PodcastEpisodeFilter.title,
  });

  EpisodesState copyWith({
    List<Audio>? allEpisodes,
    List<Audio>? episodes,
    int? displayedCount,
    int? totalCount,
    bool? hasMore,
    AudioSortOrder? order,
    bool? showSearch,
    String? Function()? searchQuery,
    PodcastEpisodeFilter? filter,
  }) => EpisodesState(
    allEpisodes: allEpisodes ?? this.allEpisodes,
    episodes: episodes ?? this.episodes,
    displayedCount: displayedCount ?? this.displayedCount,
    totalCount: totalCount ?? this.totalCount,
    hasMore: hasMore ?? this.hasMore,
    order: order ?? this.order,
    showSearch: showSearch ?? this.showSearch,
    searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
    filter: filter ?? this.filter,
  );
}

@riverpod
class EpisodesManager extends _$EpisodesManager {
  static const int pageSize = 25;

  late final PodcastService _podcastService = di<PodcastService>();

  List<Audio> _rawEpisodes = [];
  int _displayedCount = pageSize;
  bool _showSearch = false;
  String? _searchQuery;
  PodcastEpisodeFilter _filter = PodcastEpisodeFilter.title;
  AudioSortOrder? _order;

  @override
  Future<EpisodesState> build(String feedUrl) async {
    final hideCompleted = ref.watch(podcastUpdatesOnlyManagerProvider);
    final showDownloadsOnly = ref.watch(podcastDownloadsOnlyManagerProvider);
    ref.watch(audioProgressManagerProvider);
    ref.watch(downloadManagerProvider);

    if (_rawEpisodes.isEmpty) {
      _rawEpisodes = await _podcastService.findEpisodes(
        feedUrl: feedUrl,
        tryFromDbOnly: true,
        order: _order,
      );
    }

    if (_order == null) {
      final ascendingFeeds = await _podcastService.ascendingPodcasts;
      _order = ascendingFeeds.contains(feedUrl)
          ? AudioSortOrder.ascending
          : AudioSortOrder.descending;
    }

    return _computeState(
      hideCompletedEpisodes: hideCompleted,
      showDownloadsOnly: showDownloadsOnly,
    );
  }

  EpisodesState _computeState({
    required bool hideCompletedEpisodes,
    required bool showDownloadsOnly,
  }) {
    final downloadManager = ref.read(downloadManagerProvider.notifier);
    final lastPositions = ref.read(audioProgressManagerProvider).lastPositions;

    final filtered = _rawEpisodes
        .where((a) {
          if (_searchQuery == null || _searchQuery!.trim().isEmpty) return true;
          return switch (_filter) {
            PodcastEpisodeFilter.title =>
              a.title?.toLowerCase().contains(_searchQuery!.toLowerCase()) ??
                  false,
            PodcastEpisodeFilter.description =>
              a.episodeDescription?.toLowerCase().contains(
                    _searchQuery!.toLowerCase(),
                  ) ??
                  false,
          };
        })
        .where((audio) {
          if (!hideCompletedEpisodes) return true;
          if (audio.url == null) return false;
          return audio.durationMs != null &&
              lastPositions[audio.url]?.inMilliseconds !=
                  audio.durationMs?.toInt();
        })
        .where((audio) {
          if (!showDownloadsOnly) return true;
          return downloadManager.hasDownload(audio);
        })
        .toList();

    final count = _displayedCount.clamp(0, filtered.length);
    final visible = filtered
        .take(count == 0 && filtered.isNotEmpty ? pageSize : count)
        .toList();

    return EpisodesState(
      allEpisodes: filtered,
      episodes: visible,
      displayedCount: _displayedCount,
      totalCount: filtered.length,
      hasMore: _displayedCount < filtered.length,
      order: _order ?? AudioSortOrder.descending,
      showSearch: _showSearch,
      searchQuery: _searchQuery,
      filter: _filter,
    );
  }

  void loadMore() {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    _displayedCount = (_displayedCount + pageSize).clamp(
      0,
      current.allEpisodes.length,
    );
    final visible = current.allEpisodes.take(_displayedCount).toList();
    state = AsyncData(
      current.copyWith(
        displayedCount: _displayedCount,
        episodes: visible,
        hasMore: _displayedCount < current.allEpisodes.length,
      ),
    );
  }

  void toggleShowSearch() {
    _showSearch = !_showSearch;
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(showSearch: _showSearch));
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _displayedCount = pageSize;
    final hideCompleted = ref.read(podcastUpdatesOnlyManagerProvider);
    final showDownloadsOnly = ref.read(podcastDownloadsOnlyManagerProvider);
    state = AsyncData(
      _computeState(
        hideCompletedEpisodes: hideCompleted,
        showDownloadsOnly: showDownloadsOnly,
      ),
    );
  }

  void setFilter() {
    _filter = switch (_filter) {
      PodcastEpisodeFilter.title => PodcastEpisodeFilter.description,
      PodcastEpisodeFilter.description => PodcastEpisodeFilter.title,
    };
    _displayedCount = pageSize;
    final hideCompleted = ref.read(podcastUpdatesOnlyManagerProvider);
    final showDownloadsOnly = ref.read(podcastDownloadsOnlyManagerProvider);
    state = AsyncData(
      _computeState(
        hideCompletedEpisodes: hideCompleted,
        showDownloadsOnly: showDownloadsOnly,
      ),
    );
  }

  Future<void> reorder(AudioSortOrder order) async {
    _order = order;
    _displayedCount = pageSize;
    await _podcastService.reorderPodcast(feedUrl: feedUrl, order: order);
    _rawEpisodes = await _podcastService.findEpisodes(
      feedUrl: feedUrl,
      tryFromDbOnly: true,
      order: order,
    );
    final hideCompleted = ref.read(podcastUpdatesOnlyManagerProvider);
    final showDownloadsOnly = ref.read(podcastDownloadsOnlyManagerProvider);
    state = AsyncData(
      _computeState(
        hideCompletedEpisodes: hideCompleted,
        showDownloadsOnly: showDownloadsOnly,
      ),
    );
  }

  Future<void> refresh() async {
    _displayedCount = pageSize;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _rawEpisodes = await _podcastService.findEpisodes(
        feedUrl: feedUrl,
        tryFromDbOnly: false,
        order: _order,
      );
      final hideCompleted = ref.read(podcastUpdatesOnlyManagerProvider);
      final showDownloadsOnly = ref.read(podcastDownloadsOnlyManagerProvider);
      return _computeState(
        hideCompletedEpisodes: hideCompleted,
        showDownloadsOnly: showDownloadsOnly,
      );
    });
  }
}
