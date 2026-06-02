import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../search_manager.dart';
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
      di<SearchManager>().search();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loading = watchValue((SearchManager m) => m.searchCommand.isRunning);

    final items = watchValue(
      (SearchManager m) => m.podcastSearchResult.select((v) => v?.items),
    );

    final searchResultItems = widget.take != null
        ? items?.take(widget.take!)
        : items;

    if (searchResultItems == null || searchResultItems.isEmpty) {
      if (loading) {
        return SliverGrid.builder(
          itemCount: 50,
          gridDelegate: audioCardGridDelegate,
          itemBuilder: (context, index) {
            return const AudioCard(bottom: AudioCardBottom(text: ''));
          },
        );
      }

      return SliverNoSearchResultPage(
        message: Text(
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
