import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../l10n.dart';
import 'podcast_utils.dart';

class PodcastsDiscoverGrid extends StatefulWidget {
  const PodcastsDiscoverGrid({
    super.key,
    required this.checkingForUpdates,
    required this.limit,
    required this.searchResult,
    required this.incrementLimit,
  });

  final bool checkingForUpdates;
  final int limit;
  final SearchResult? searchResult;
  final Future<void> Function() incrementLimit;

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
    if (widget.searchResult == null || widget.checkingForUpdates) {
      return LoadingGrid(limit: widget.limit);
    } else if (widget.searchResult?.items.isEmpty == true) {
      return NoSearchResultPage(message: Text(context.l10n.noPodcastFound));
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _controller,
            padding: gridPadding,
            itemCount: widget.searchResult!.resultCount,
            gridDelegate: imageGridDelegate,
            itemBuilder: (context, index) {
              final podcastItem = widget.searchResult!.items.elementAt(index);

              final art = podcastItem.artworkUrl600 ?? podcastItem.artworkUrl;
              final image = SafeNetworkImage(
                url: art,
                fit: BoxFit.cover,
                height: kSmallCardHeight,
                width: kSmallCardHeight,
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
        if (widget.searchResult != null && widget.searchResult!.resultCount > 0)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await widget.incrementLimit();
                    await Future.delayed(const Duration(milliseconds: 300));
                    _controller.jumpTo(_controller.position.maxScrollExtent);
                  },
                  child: const Text('Load more'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
