import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../common.dart';
import '../../../constants.dart';
import '../../../l10n.dart';
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
    final model = di<PodcastModel>();
    final setLimit = model.setLimit;
    Future<void> incrementLimit() async {
      setLimit(limit + 20);
      await model.search();
    }

    if (searchResult == null || widget.checkingForUpdates) {
      return LoadingGrid(limit: limit);
    } else if (searchResult.items.isEmpty == true) {
      return NoSearchResultPage(message: Text(context.l10n.noPodcastFound));
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _controller,
            padding: gridPadding,
            itemCount: searchResult.resultCount,
            gridDelegate: audioCardGridDelegate,
            itemBuilder: (context, index) {
              final podcastItem = searchResult.items.elementAt(index);

              final art = podcastItem.artworkUrl600 ?? podcastItem.artworkUrl;
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
        if (searchResult.resultCount > 0)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await incrementLimit();
                    await Future.delayed(const Duration(milliseconds: 300));
                    _controller.jumpTo(_controller.position.maxScrollExtent);
                  },
                  child: Text(context.l10n.loadMore),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
