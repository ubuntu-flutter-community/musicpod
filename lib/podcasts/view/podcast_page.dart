import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
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
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../podcast_model.dart';
import 'podcast_page_control_panel.dart';
import 'podcast_page_header.dart';
import 'sliver_podcast_page_list.dart';
import 'sliver_podcast_page_search_field.dart';

class PodcastPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PodcastPage({
    super.key,
    this.imageUrl,
    required this.feedUrl,
    this.preFetchedEpisodes,
    required this.title,
  });

  final String? imageUrl;

  /// The feedUrl
  final String feedUrl;
  final String title;
  final List<Audio>? preFetchedEpisodes;

  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  @override
  void initState() {
    super.initState();
    final libraryModel = di<LibraryModel>();
    if (!libraryModel.isPageInLibrary(widget.feedUrl)) return;

    final episodes =
        widget.preFetchedEpisodes ?? libraryModel.getPodcast(widget.feedUrl);

    if (episodes == null || episodes.isEmpty) return;

    Future.delayed(const Duration(milliseconds: 500)).then(
      (_) {
        final episodesWithDownloads = episodes
            .map((e) => e.copyWith(path: libraryModel.getDownload(e.url)))
            .toList();
        di<PodcastModel>().update(
          oldPodcasts: {
            widget.feedUrl: episodesWithDownloads,
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final episodes = widget.preFetchedEpisodes ??
        watchPropertyValue((LibraryModel m) => m.getPodcast(widget.feedUrl));
    watchPropertyValue((PlayerModel m) => m.lastPositions?.length);
    watchPropertyValue((LibraryModel m) => m.downloadsLength);
    final showSearch =
        watchPropertyValue((PodcastModel m) => m.getShowSearch(widget.feedUrl));
    final searchQuery = watchPropertyValue(
      (PodcastModel m) => m.getSearchQuery(widget.feedUrl),
    );

    final libraryModel = di<LibraryModel>();
    if (watchPropertyValue(
      (LibraryModel m) => m.showPodcastAscending(widget.feedUrl),
    )) {
      sortListByAudioFilter(
        audioFilter: AudioFilter.year,
        audios: episodes ?? [],
      );
    }
    final filter = watchPropertyValue((PodcastModel m) => m.filter);
    final episodesWithDownloads = (episodes ?? [])
        .map((e) => e.copyWith(path: libraryModel.getDownload(e.url)))
        .where((e) => e.title != null && e.description != null)
        .where(
          (e) => (searchQuery == null || searchQuery.trim().isEmpty)
              ? true
              : switch (filter) {
                  PodcastEpisodeFilter.title =>
                    e.title!.toLowerCase().contains(searchQuery.toLowerCase()),
                  PodcastEpisodeFilter.description => e.description!
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase())
                },
        )
        .toList();

    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                di<LibraryModel>().push(pageId: PageIDs.searchPage);
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
              oldPodcasts: {widget.feedUrl: episodesWithDownloads},
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
                      title: widget.title,
                      imageUrl: widget.imageUrl,
                      episodes: episodes,
                    ),
                  ),
                ),
                SliverAudioPageControlPanel(
                  controlPanel: PodcastPageControlPanel(
                    feedUrl: widget.feedUrl,
                    audios: episodesWithDownloads,
                    title: widget.title,
                  ),
                ),
                if (showSearch)
                  SliverPodcastPageSearchField(
                    feedUrl: widget.feedUrl,
                  ),
                SliverPadding(
                  padding: getAdaptiveHorizontalPadding(
                    min: AppConfig.isMobilePlatform ? 0 : 15,
                    constraints: constraints,
                  ).copyWith(bottom: bottomPlayerPageGap ?? kLargestSpace),
                  sliver: SliverPodcastPageList(
                    audios: episodesWithDownloads,
                    pageId: widget.feedUrl,
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
