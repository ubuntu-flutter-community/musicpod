import '../../common/data/audio.dart';
import '../../common/view/audio_filter.dart';
import 'podcast_episode_filter.dart';

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
