import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_filter.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_audio_page_control_panel.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../../settings/settings_model.dart';
import '../podcast_model.dart';
import 'podcast_page_control_panel.dart';
import 'podcast_page_header.dart';
import 'sliver_podcast_page_list.dart';
import 'sliver_podcast_page_search_field.dart';

class PodcastPage extends StatelessWidget with WatchItMixin {
  const PodcastPage({
    super.key,
    this.imageUrl,
    required this.feedUrl,
    required this.episodes,
    required this.title,
  });

  final String feedUrl;
  final String? imageUrl;
  final String title;
  final List<Audio> episodes;

  @override
  Widget build(BuildContext context) {
    final showPodcastsAscending = watchPropertyValue(
      (LibraryModel m) => m.showPodcastAscending(feedUrl),
    );
    watchPropertyValue((LibraryModel m) => m.podcastUpdatesLength);

    watchPropertyValue(
      (PodcastModel m) => m.getPodcastEpisodesFromCache(feedUrl)?.length,
    );
    watchPropertyValue(
      (PodcastModel m) => m.getPodcastEpisodesFromCache(feedUrl)?.hashCode,
    );
    final episodes =
        di<PodcastModel>().getPodcastEpisodesFromCache(feedUrl) ??
        this.episodes;

    watchPropertyValue((PlayerModel m) => m.lastPositions?.length);
    watchPropertyValue((LibraryModel m) => m.downloadsLength);
    final showSearch = watchPropertyValue(
      (PodcastModel m) => m.getShowSearch(feedUrl),
    );
    final searchQuery = watchPropertyValue(
      (PodcastModel m) => m.getSearchQuery(feedUrl),
    );

    final hideCompletedEpisodes = watchPropertyValue(
      (SettingsModel m) => m.hideCompletedEpisodes,
    );

    final filter = watchPropertyValue((PodcastModel m) => m.filter);
    final episodesWithDownloads = episodes
        .map((e) => e.copyWith(path: di<LibraryModel>().getDownload(e.url)))
        .where((e) => e.title != null && e.description != null)
        .where(
          (e) => (searchQuery == null || searchQuery.trim().isEmpty)
              ? true
              : switch (filter) {
                  PodcastEpisodeFilter.title => e.title!.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
                  PodcastEpisodeFilter.description =>
                    e.description!.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
                },
        )
        .where((e) {
          if (!hideCompletedEpisodes) return true;
          if (e.url == null) return false;

          return e.durationMs != null &&
              di<PlayerModel>().getLastPosition(e.url)?.inMilliseconds !=
                  e.durationMs;
        })
        .toList();

    sortListByAudioFilter(
      audioFilter: AudioFilter.year,
      audios: episodesWithDownloads,
      descending: !showPodcastsAscending,
    );

    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
                di<SearchModel>()
                  ..setAudioType(AudioType.podcast)
                  ..setSearchType(SearchType.podcastTitle);
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () async => di<PodcastModel>().update(
              feedUrls: {feedUrl},
              updateMessage: context.l10n.newEpisodeAvailable,
              multiUpdateMessage: (length) =>
                  context.l10n.newEpisodesAvailableFor(length),
            ),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: getAdaptiveHorizontalPadding(
                    constraints: constraints,
                    min: 40,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: PodcastPageHeader(
                      title: title,
                      imageUrl: imageUrl,
                      episodes: episodes,
                      showFallbackIcon: true,
                    ),
                  ),
                ),
                SliverAudioPageControlPanel(
                  controlPanel: PodcastPageControlPanel(
                    feedUrl: feedUrl,
                    audios: episodesWithDownloads,
                    title: title,
                    imageUrl: imageUrl,
                  ),
                ),
                if (showSearch) SliverPodcastPageSearchField(feedUrl: feedUrl),
                SliverPadding(
                  padding: getAdaptiveHorizontalPadding(
                    constraints: constraints,
                  ).copyWith(bottom: bottomPlayerPageGap ?? kLargestSpace),
                  sliver: SliverPodcastPageList(
                    audios: episodesWithDownloads,
                    pageId: feedUrl,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
