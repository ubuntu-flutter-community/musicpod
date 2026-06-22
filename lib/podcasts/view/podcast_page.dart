import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/clean_up_caches.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../player/player_manager.dart';
import '../../search/search_manager.dart';
import '../../search/search_type.dart';
import '../../settings/settings_manager.dart';
import '../data/podcast_episode_filter.dart';
import '../data/podcast_update_capsule.dart';
import '../manager/download_manager.dart';
import '../manager/episodes_manager.dart';
import '../manager/podcast_genre_manager.dart';
import '../manager/podcast_manager.dart';
import '../manager/podcast_updates_manager.dart';
import '../manager/subscribed_podcasts_manager.dart';
import 'podcast_error_page.dart';
import 'podcast_loading_page.dart';
import 'podcast_page_control_panel.dart';
import 'podcast_page_header.dart';
import 'podcast_page_search_field.dart';
import 'sliver_podcast_page_list.dart';

class PodcastPage extends StatelessWidget with WatchItMixin {
  const PodcastPage({super.key, required this.feedUrl, this.genre});

  final String feedUrl;
  final String? genre;

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild((_) {
      if (genre != null) {
        di<PodcastGenreManager>(
          param1: feedUrl,
        ).updateCommand.run((genre: genre!));
      }
      cleanUpLocalAudioCaches();
      di<PodcastUpdatesManager>().command.run(
        PodcastUpdateCapsule(
          feedUrls: [feedUrl],
          type: PodcastUpdateType.remove,
        ),
      );
    });

    onDispose(() {
      if (!di<SubscribedPodcastsManager>().command.value.contains(feedUrl)) {
        cleanUpUnusedPodcasts(deleteMeUrls: {feedUrl});
      }
    });

    final episodesResults = watchValue(
      (EpisodesManager m) => m.command.results,
      param1: feedUrl,
    );

    if (episodesResults.isRunning) {
      return const PodcastLoadingPage(child: Center(child: Progress()));
    }

    if (episodesResults.hasError) {
      return PodcastErrorPage(
        error: episodesResults.error!,
        feedUrl: feedUrl,
        stackTrace: episodesResults.stackTrace ?? StackTrace.current,
      );
    }

    registerHandler(
      select: (PlayerManager m) => m.toggleAudiosProgressCommand.results,
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

    registerHandler(
      select: (SubscribedPodcastsManager m) => m.command.results,
      handler: (context, result, cancel) {
        if (result.hasData && result.data?.contains(feedUrl) == false) {
          if (context.canPop()) {
            context.pop();
          }
        }
      },
    );

    final showSearch = watchValue((PodcastManager m) => m.showSearch);
    final searchQuery = watchValue((PodcastManager m) => m.searchQuery);

    final showDownloadsOnly = watchValue((PodcastManager m) => m.downloadsOnly);
    final hideCompletedEpisodes = watchPropertyValue(
      (SettingsManager m) => m.hideCompletedEpisodes,
    );

    final lastPositions = watchValue(
      (PlayerManager m) => m.toggleAudiosProgressCommand,
    );

    final filter = watchValue((PodcastManager m) => m.filter);

    watchValue((DownloadManager m) => m.downloadCommands);

    final freshEspidodes = episodesResults.data;

    final filteredEpisodes = freshEspidodes
        ?.where((a) => a.title != null && a.episodeDescription != null)
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

    final title =
        freshEspidodes?.firstOrNull?.podcastTitle ?? context.l10n.podcast;
    return Scaffold(
      appBar: HeaderBar(
        title: isMobile ? null : Text(title),

        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
                di<SearchManager>()
                  ..setAudioType(AudioType.podcast)
                  ..setSearchType(SearchType.podcastTitle);
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh:
            di<SubscribedPodcastsManager>().command.value.contains(feedUrl)
            ? () async => di<PodcastUpdatesManager>().command
                  .runAsync(
                    PodcastUpdateCapsule(
                      feedUrls: [feedUrl],
                      type: PodcastUpdateType.update,
                    ),
                  )
                  .then(
                    (_) => di<EpisodesManager>(param1: feedUrl).command.run(),
                  )
            : () async {},
        child: AdaptiveMultiLayoutBody(
          header: PodcastPageHeader(
            feedUrl: feedUrl,
            title: title,
            episodes: filteredEpisodes,
            showFallbackIcon: true,
          ),
          sliverBody: (constraints) => (freshEspidodes?.isEmpty ?? true)
              ? SliverNoSearchResultPage(
                  message: Text(context.l10n.podcastFeedIsEmpty),
                )
              : SliverPodcastPageList(
                  audios: filteredEpisodes ?? [],
                  pageId: feedUrl,
                ),
          controlPanel: (freshEspidodes?.isEmpty ?? true)
              ? const SizedBox.shrink()
              : PodcastPageControlPanel(
                  feedUrl: feedUrl,
                  audios: filteredEpisodes ?? [],
                  title: title,
                ),
          secondControlPanel: (freshEspidodes?.isEmpty ?? true)
              ? const SizedBox.shrink()
              : (showSearch
                    ? PodcastPageSearchField(feedUrl: feedUrl, sliver: false)
                    : null),
          secondSliverControlPanel: (freshEspidodes?.isEmpty ?? true)
              ? const SizedBox.shrink()
              : (showSearch
                    ? PodcastPageSearchField(feedUrl: feedUrl, sliver: true)
                    : null),
        ),

        //
      ),
    );
  }
}
