import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/audio_filter.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../../settings/settings_model.dart';
import '../podcast_manager.dart';
import 'podcast_page_control_panel.dart';
import 'podcast_page_header.dart';
import 'podcast_page_search_field.dart';
import 'sliver_podcast_page_list.dart';

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
      (PodcastManager m) => m.showPodcastAscending(feedUrl),
    );

    final showDownloadsOnly = watchValue((PodcastManager m) => m.downloadsOnly);

    final showSearch = watchValue((PodcastManager m) => m.showSearch);
    final searchQuery = watchValue((PodcastManager m) => m.searchQuery);

    final hideCompletedEpisodes = watchPropertyValue(
      (SettingsModel m) => m.hideCompletedEpisodes,
    );

    final filter = watchValue((PodcastManager m) => m.filter);
    final filteredEpisodes = episodes
        .where((e) => e.title != null && e.episodeDescription != null)
        .where(
          (e) => (searchQuery == null || searchQuery.trim().isEmpty)
              ? true
              : switch (filter) {
                  PodcastEpisodeFilter.title => e.title!.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
                  PodcastEpisodeFilter.description =>
                    e.episodeDescription!.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
                },
        )
        .where((e) {
          if (!hideCompletedEpisodes) return true;
          if (e.url == null) return false;

          return e.durationMs != null &&
              di<PlayerModel>().getLastPosition(e.url)?.inMilliseconds !=
                  e.durationMs?.toInt();
        })
        .where(
          (e) => showDownloadsOnly
              ? di<PodcastManager>().getDownload(e.url) != null
              : true,
        )
        .toList();

    sortListByAudioFilter(
      audioFilter: AudioFilter.year,
      audios: filteredEpisodes,
      descending: !showPodcastsAscending,
    );

    return Scaffold(
      appBar: HeaderBar(
        title: Text(title),
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
      body: RefreshIndicator(
        onRefresh: di<PodcastManager>().isPodcastSubscribed(feedUrl)
            ? () async => di<PodcastManager>()
                  .checkForUpdateAndRefreshIfNeededCommand
                  .runAsync((
                    feedUrls: [feedUrl],
                    multiUpdateMessage: (length) => context.mounted
                        ? context.l10n.newEpisodesAvailableFor(length)
                        : context.l10n.updateAvailable,
                  ))
            : () async {},
        child: AdaptiveMultiLayoutBody(
          header: PodcastPageHeader(
            title: title,
            imageUrl: imageUrl,
            episodes: filteredEpisodes,
            showFallbackIcon: true,
          ),
          sliverBody: (constraints) =>
              SliverPodcastPageList(audios: filteredEpisodes, pageId: feedUrl),
          controlPanel: PodcastPageControlPanel(
            feedUrl: feedUrl,
            audios: filteredEpisodes,
            title: title,
            imageUrl: imageUrl,
          ),
          secondControlPanel: showSearch
              ? PodcastPageSearchField(feedUrl: feedUrl, sliver: false)
              : null,
          secondSliverControlPanel: showSearch
              ? PodcastPageSearchField(feedUrl: feedUrl, sliver: true)
              : null,
        ),

        //
      ),
    );
  }
}
