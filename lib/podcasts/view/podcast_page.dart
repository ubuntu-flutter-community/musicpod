import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../dependencies.dart';
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

class PodcastPage extends ConsumerStatefulWidget {
  const PodcastPage({super.key, required this.feedUrl, this.genre});

  final String feedUrl;
  final String? genre;

  @override
  ConsumerState<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends ConsumerState<PodcastPage> {
  void _onProgressResults() {
    final results =
        di<PlayerManager>().toggleAudiosProgressCommand.results.value;
    if (!mounted) return;
    if (results.paramData?.audios.any((a) => a.durationMs == null) == true) {
      context.toast(
        Text(context.l10n.podcastDoesNotSendEpisodeDuration),
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    di<PlayerManager>()
        .toggleAudiosProgressCommand
        .results
        .addListener(_onProgressResults);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.genre != null) {
        ref
            .read(podcastGenreManagerProvider(widget.feedUrl).notifier)
            .updateGenre(widget.genre!);
      }

      ref.read(podcastUpdatesManagerProvider.notifier).run(
        PodcastUpdateCapsule(
          feedUrls: [widget.feedUrl],
          type: PodcastUpdateType.remove,
        ),
      );
    });
  }

  @override
  void dispose() {
    di<PlayerManager>()
        .toggleAudiosProgressCommand
        .results
        .removeListener(_onProgressResults);
    ref.read(podcastCleanManagerProvider.notifier).clean(reclaimDiskSpace: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final episodesAsync = ref.watch(episodesManagerProvider(widget.feedUrl));

    return episodesAsync.when(
      data: (_) => _PodcastPage(feedUrl: widget.feedUrl),
      loading: () => episodesAsync.hasValue
          ? _PodcastPage(feedUrl: widget.feedUrl)
          : PodcastLoadingPage(feedUrl: widget.feedUrl),
      error: (error, stackTrace) => PodcastErrorPage(
        error: error,
        feedUrl: widget.feedUrl,
        stackTrace: stackTrace,
      ),
    );
  }
}

class _PodcastPage extends ConsumerWidget {
  const _PodcastPage({required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSearch =
        ref.watch(episodesManagerProvider(feedUrl)).value?.showSearch ?? false;

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
      body: RefreshIndicator(
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
      ),
    );
  }
}
