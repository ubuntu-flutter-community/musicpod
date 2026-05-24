import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di<SearchModel>().search();
    });
  }

  @override
  Widget build(BuildContext context) {
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
