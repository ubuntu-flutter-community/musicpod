import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../manager/search_manager.dart';
import 'podcast_card.dart';

class SliverPodcastSearchResults extends ConsumerStatefulWidget {
  const SliverPodcastSearchResults({super.key, this.take});

  final int? take;

  @override
  ConsumerState<SliverPodcastSearchResults> createState() =>
      _SliverPodcastSearchResultsState();
}

class _SliverPodcastSearchResultsState
    extends ConsumerState<SliverPodcastSearchResults> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchManagerProvider.notifier).search();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(
      searchManagerProvider.select((s) => s.isLoading),
    );

    final items = ref.watch(
      searchManagerProvider.select((s) => s.podcastSearchResult),
    )?.items;

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
