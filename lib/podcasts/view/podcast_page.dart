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
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../../settings/settings_model.dart';
import '../data/podcast_episode_filter.dart';
import '../data/podcast_update_capsule.dart';
import '../download_manager.dart';
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
    onDispose(() {
      di<PodcastManager>().cleanUpCommand.run((feedUrl: feedUrl, name: title));
    });

    final showPodcastsAscending = watchValue(
      (PodcastManager m) =>
          m.reorderPodcastCommand.select((v) => v.contains(feedUrl)),
    );

    registerHandler(
      select: (PlayerModel m) => m.toggleAudiosProgressCommand.results,
      handler: (context, results, cancel) {
        if (results.paramData?.audios.any((a) => a.durationMs == null) ==
            true) {
          context.toast(
            Text(context.l10n.podcastDoesNotSendEpisodeDuration),
            duration: const Duration(seconds: 5),
          );
        }
      },
    );

    final showDownloadsOnly = watchValue((PodcastManager m) => m.downloadsOnly);

    final showSearch = watchValue((PodcastManager m) => m.showSearch);
    final searchQuery = watchValue((PodcastManager m) => m.searchQuery);

    final hideCompletedEpisodes = watchPropertyValue(
      (SettingsModel m) => m.hideCompletedEpisodes,
    );

    final lastPositions = watchValue(
      (PlayerModel m) => m.toggleAudiosProgressCommand,
    );

    watchValue((DownloadManager m) => m.commands);

    final filter = watchValue((PodcastManager m) => m.filter);
    final filteredEpisodes = episodes
        .where((a) => a.title != null && a.episodeDescription != null)
        .where(
          (a) => (searchQuery == null || searchQuery.trim().isEmpty)
              ? true
              : switch (filter) {
                  PodcastEpisodeFilter.title => a.title!.toLowerCase().contains(
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
              lastPositions?[audio.url]?.inMilliseconds !=
                  audio.durationMs?.toInt();
        })
        .where((audio) {
          if (!showDownloadsOnly) return true;

          return di<DownloadManager>().hasDownload(audio);
        })
        .toList();

    sortListByAudioFilter(
      audioFilter: AudioFilter.year,
      audios: filteredEpisodes,
      descending: !showPodcastsAscending,
    );

    return Scaffold(
      appBar: HeaderBar(
        title: isMobile ? null : Text(title),
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
            ? () async => di<PodcastManager>().updatesCommand.runAsync(
                PodcastUpdateCapsule(
                  feedUrls: [feedUrl],
                  type: PodcastUpdateType.update,
                ),
              )
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
