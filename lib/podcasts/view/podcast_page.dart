import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../player/manager/player_manager.dart';
import '../../search/data/search_type.dart';
import '../../search/manager/search_manager.dart';
import '../data/podcast_update_capsule.dart';
import '../manager/episodes_manager.dart';
import '../manager/podcast_clean_manager.dart';
import '../manager/podcast_genre_manager.dart';
import '../manager/podcast_short_info_manager.dart';
import '../manager/podcast_updates_manager.dart';
import '../manager/subscribed_podcasts_manager.dart';
import 'podcast_error_page.dart';
import 'podcast_loading_page.dart';
import 'podcast_page_control_panel.dart';
import 'podcast_page_header.dart';
import 'podcast_page_search_field.dart';
import 'podcast_page_title.dart';
import 'sliver_podcast_page_list.dart';

class PodcastPage extends StatelessWidget with WatchItMixin {
  const PodcastPage({super.key, required this.feedUrl, this.genre});

  final String feedUrl;
  final String? genre;

  @override
  Widget build(BuildContext context) {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      if (genre != null) {
        container.read(podcastGenreManagerProvider(feedUrl).notifier).updateGenre(genre!);
      }

      container.read(podcastUpdatesManagerProvider.notifier).run(
        PodcastUpdateCapsule(
          feedUrls: [feedUrl],
          type: PodcastUpdateType.remove,
        ),
      );
    });

    onDispose(
      () => ProviderScope.containerOf(
        context,
        listen: false,
      ).read(podcastCleanManagerProvider.notifier).clean(reclaimDiskSpace: false),
    );

    return watchValue(
      (EpisodesManager m) => m.command.results,
      param1: feedUrl,
    ).toWidget(
      whileRunning: (lastResult, param) => lastResult?.episodes != null
          ? _PodcastPage(feedUrl: feedUrl)
          : PodcastLoadingPage(feedUrl: feedUrl),
      onError: (error, lastResult, param) => PodcastErrorPage(
        error: error,
        feedUrl: feedUrl,
        stackTrace:
            di<EpisodesManager>(
              param1: feedUrl,
            ).command.results.value.stackTrace ??
            StackTrace.current,
      ),
      onData: (result, param) => _PodcastPage(feedUrl: feedUrl),
    );
  }
}

class _PodcastPage extends StatelessWidget with WatchItMixin {
  const _PodcastPage({required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context) {
    final showSearch = watchValue(
      (EpisodesManager m) => m.showSearch,
      param1: feedUrl,
    );

    return Scaffold(
      appBar: HeaderBar(
        title: isMobile ? null : PodcastPageTitle(feedUrl: feedUrl),
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
      body: Consumer(
        builder: (context, ref, _) {
          final isSubscribed =
              ref
                  .watch(subscribedPodcastsManagerProvider)
                  .value
                  ?.contains(feedUrl) ??
              false;
          final shortInfo =
              ref.watch(podcastShortInfoManagerProvider(feedUrl)).value;
          if (shortInfo == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.invalidate(podcastShortInfoManagerProvider(feedUrl));
            });
          }
          return RefreshIndicator(
            onRefresh: isSubscribed
                ? () => ref.read(podcastUpdatesManagerProvider.notifier).run(
                    PodcastUpdateCapsule(
                      feedUrls: [feedUrl],
                      type: PodcastUpdateType.update,
                    ),
                  )
                : () async {},
            child: AdaptiveMultiLayoutBody(
              header: PodcastPageHeader(feedUrl: feedUrl),
              sliverBody: (constraints) =>
                  SliverPodcastPageList(feedUrl: feedUrl),
              controlPanel: PodcastPageControlPanel(feedUrl: feedUrl),
              secondControlPanel: (showSearch
                  ? PodcastPageSearchField(feedUrl: feedUrl, sliver: false)
                  : null),
              secondSliverControlPanel: (showSearch
                  ? PodcastPageSearchField(feedUrl: feedUrl, sliver: true)
                  : null),
            ),
          );
        },
      ),
    );
  }
}
