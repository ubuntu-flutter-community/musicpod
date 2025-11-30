import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../podcasts/podcast_model.dart';
import '../search_model.dart';
import 'podcast_card.dart';

class SliverPodcastSearchResults extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const SliverPodcastSearchResults({super.key, this.take});

  final int? take;

  @override
  State<SliverPodcastSearchResults> createState() =>
      _SliverPodcastSearchResultsState();
}

class _SliverPodcastSearchResultsState
    extends State<SliverPodcastSearchResults> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    di<PodcastModel>()
        .init(updateMessage: context.l10n.newEpisodeAvailable)
        .then((_) => di<SearchModel>().search());
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);

    if (!isOnline) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: OfflineBody(),
      );
    }

    final loading = watchPropertyValue((SearchModel m) => m.loading);

    final results = watchPropertyValue(
      (SearchModel m) => m.podcastSearchResult?.items,
    );
    final searchResultItems = widget.take != null
        ? results?.take(widget.take!)
        : results;

    if (searchResultItems == null || searchResultItems.isEmpty) {
      return SliverNoSearchResultPage(
        message: loading
            ? const Progress()
            : Text(
                searchResultItems == null
                    ? context.l10n.search
                    : context.l10n.noPodcastFound,
              ),
      );
    }

    return SliverGrid.builder(
      itemCount: searchResultItems.length,
      gridDelegate: audioCardGridDelegate,
      itemBuilder: (context, index) {
        final item = searchResultItems.elementAt(index);
        return PodcastCard(key: ValueKey(item.feedUrl ?? index), item: item);
      },
    );
  }
}

class SliverPodcastSearchCountryChartsResults extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const SliverPodcastSearchCountryChartsResults({super.key});

  @override
  State<SliverPodcastSearchCountryChartsResults> createState() =>
      _SliverPodcastSearchCountryChartsResultsState();
}

class _SliverPodcastSearchCountryChartsResultsState
    extends State<SliverPodcastSearchCountryChartsResults> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    di<PodcastModel>()
        .init(updateMessage: context.l10n.newEpisodeAvailable)
        .then((_) => di<SearchModel>().fetchPodcastChartsPeak());
  }

  @override
  Widget build(BuildContext context) {
    final loading = watchPropertyValue((SearchModel m) => m.loading);

    final results = watchPropertyValue(
      (SearchModel m) => m.podcastChartsPeak?.items,
    );

    if (results == null || loading) {
      return const Center(child: Progress());
    } else if (results.isEmpty) {
      return const NoSearchResultPage();
    }

    return SizedBox(
      height: kAudioCardDimension + kAudioCardBottomHeight,
      child: ListView.separated(
        itemCount: results.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = results.elementAt(index);
          return PodcastCard(key: ValueKey(item.feedUrl ?? index), item: item);
        },
        separatorBuilder: (context, index) =>
            const SizedBox(width: kMediumSpace),
      ),
    );
  }
}
