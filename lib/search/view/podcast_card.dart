import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../podcasts/podcast_model.dart';
import '../../podcasts/view/lazy_podcast_page.dart';

class PodcastCard extends StatelessWidget with WatchItMixin {
  const PodcastCard({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final feedUrl = item.feedUrl;

    return AudioCard(
      key: ValueKey(feedUrl),
      bottom: AudioCardBottom(text: item.collectionName ?? item.trackName),
      image: SafeNetworkImage(
        url: item.artworkUrl600 ?? item.artworkUrl,
        fit: BoxFit.cover,
        height: audioCardDimension,
        width: audioCardDimension,
      ),
      onPlay: feedUrl == null
          ? null
          : () =>
                showFutureLoadingDialog(
                  barrierDismissible: true,
                  title: context.l10n.loadingPodcastFeed,
                  context: context,
                  future: () => di<PodcastModel>().findEpisodes(item: item),
                ).then((res) {
                  if (res.isValue) {
                    di<PlayerModel>().startPlaylist(
                      audios: res.asValue!.value,
                      listName: feedUrl,
                    );
                  } else {
                    showSnackBar(
                      context: context,
                      content: Text(context.l10n.podcastFeedIsEmpty),
                    );
                  }
                }),
      onTap: feedUrl == null
          ? null
          : () => di<RoutingManager>().push(
              builder: (_) => LazyPodcastPage(
                podcastItem: item,
                updateMessage: context.l10n.newEpisodeAvailable,
                multiUpdateMessage: (length) =>
                    context.l10n.newEpisodesAvailableFor(length),
              ),
              pageId: feedUrl,
            ),
    );
  }
}
