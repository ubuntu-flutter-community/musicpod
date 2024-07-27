import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/loading_grid.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/safe_network_image.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../podcast_model.dart';
import '../podcast_utils.dart';

class PodcastsDiscoverGrid extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const PodcastsDiscoverGrid({
    super.key,
    required this.checkingForUpdates,
  });

  final bool checkingForUpdates;

  @override
  State<PodcastsDiscoverGrid> createState() => _PodcastsDiscoverGridState();
}

class _PodcastsDiscoverGridState extends State<PodcastsDiscoverGrid> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResult = watchPropertyValue((PodcastModel m) => m.searchResult);
    final limit = watchPropertyValue((PodcastModel m) => m.limit);

    if (searchResult == null || widget.checkingForUpdates) {
      return LoadingGrid(limit: limit);
    } else if (searchResult.items.isEmpty == true) {
      return NoSearchResultPage(message: Text(context.l10n.noPodcastFound));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: getAdaptiveHorizontalPadding(constraints),
              sliver: SliverGrid.builder(
                itemCount: searchResult.resultCount,
                gridDelegate: audioCardGridDelegate,
                itemBuilder: (context, index) {
                  final podcastItem = searchResult.items.elementAt(index);

                  final art =
                      podcastItem.artworkUrl600 ?? podcastItem.artworkUrl;
                  final image = SafeNetworkImage(
                    url: art,
                    fit: BoxFit.cover,
                    height: kAudioCardDimension,
                    width: kAudioCardDimension,
                  );

                  return AudioCard(
                    bottom: AudioCardBottom(
                      text: podcastItem.collectionName ?? podcastItem.trackName,
                    ),
                    image: image,
                    onPlay: () => searchAndPushPodcastPage(
                      context: context,
                      feedUrl: podcastItem.feedUrl,
                      itemImageUrl: art,
                      genre: podcastItem.primaryGenreName,
                      play: true,
                    ),
                    onTap: () => searchAndPushPodcastPage(
                      context: context,
                      feedUrl: podcastItem.feedUrl,
                      itemImageUrl: art,
                      genre: podcastItem.primaryGenreName,
                      play: false,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
