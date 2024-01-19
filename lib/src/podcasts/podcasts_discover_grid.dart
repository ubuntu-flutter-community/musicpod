import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../player.dart';
import '../../podcasts.dart';

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

    final selectedFeedUrl =
        context.select((PodcastModel m) => m.selectedFeedUrl);

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

              final artworkUrl600 = podcastItem.artworkUrl600;
              final image = SafeNetworkImage(
                url: artworkUrl600,
                fit: BoxFit.cover,
                height: kSmallCardHeight,
                width: kSmallCardHeight,
              );

              return AudioCard(
                bottom: AudioCardBottom(text: podcastItem.collectionName),
                image: image,
                onPlay: () async => await searchAndPushPodcastPage(
                  context: context,
                  podcastItem: podcastItem,
                  itemImageUrl: artworkUrl600,
                  genre: podcastItem.primaryGenreName,
                  selectedFeedUrl: selectedFeedUrl,
                  play: true,
                ),
                onTap: () async => await searchAndPushPodcastPage(
                  context: context,
                  podcastItem: podcastItem,
                  itemImageUrl: artworkUrl600,
                  genre: podcastItem.primaryGenreName,
                  selectedFeedUrl: selectedFeedUrl,
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

  Future<void> searchAndPushPodcastPage({
    required BuildContext context,
    required Item podcastItem,
    String? itemImageUrl,
    String? genre,
    String? selectedFeedUrl,
    bool play = false,
  }) async {
    if (podcastItem.feedUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.podcastFeedIsEmpty),
        ),
      );
      return;
    }
    final model = context.read<PodcastModel>();
    final libraryModel = context.read<LibraryModel>();
    final startPlaylist = context.read<PlayerModel>().startPlaylist;

    final setSelectedFeedUrl = model.setSelectedFeedUrl;

    setSelectedFeedUrl(podcastItem.feedUrl);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 20),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.loadingPodcastFeed),
            SizedBox(
              height: iconSize,
              width: iconSize,
              child: const Progress(),
            ),
          ],
        ),
      ),
    );

    await findEpisodes(
      feedUrl: podcastItem.feedUrl!,
      itemImageUrl: itemImageUrl,
      genre: genre,
    ).then((podcast) async {
      if (selectedFeedUrl == podcastItem.feedUrl) {
        return;
      }
      if (podcast.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.podcastFeedIsEmpty),
          ),
        );
        return;
      }

      if (play) {
        ScaffoldMessenger.of(context).clearSnackBars();

        runOrConfirm(
          context: context,
          noConfirm: podcast.length < kAudioQueueThreshHold,
          message: context.l10n.queueConfirmMessage(podcast.length.toString()),
          run: () => startPlaylist
              .call(listName: podcastItem.feedUrl!, audios: podcast)
              .then(
                (_) => setSelectedFeedUrl(null),
              ),
        );
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              final subscribed =
                  libraryModel.podcastSubscribed(podcastItem.feedUrl);
              final id = podcastItem.feedUrl;

              ScaffoldMessenger.of(context).clearSnackBars();

              return PodcastPage(
                subscribed: subscribed,
                imageUrl: podcastItem.artworkUrl600,
                addPodcast: libraryModel.addPodcast,
                removePodcast: libraryModel.removePodcast,
                audios: podcast,
                pageId: id!,
                title: podcast.firstOrNull?.album ??
                    podcast.firstOrNull?.title ??
                    podcastItem.feedUrl!,
              );
            },
          ),
        ).then((_) => setSelectedFeedUrl(null));
      }
    });
  }
}
