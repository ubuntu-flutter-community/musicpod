import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../app/data/play_anywhere_param.dart';
import '../../app/play_anywhere_manager.dart';
import '../../app/routing_manager.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../podcasts/view/podcast_page.dart';

class PodcastCard extends StatelessWidget with WatchItMixin {
  const PodcastCard({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final feedUrl = item.feedUrl;
    final genre = item.primaryGenreName ?? item.genre?.firstOrNull?.name;

    return AudioCard(
      bottom: AudioCardBottom(text: item.collectionName ?? item.trackName),
      image: SafeNetworkImage(
        url: item.artworkUrl600,
        fit: BoxFit.cover,
        height: audioCardDimension,
        width: audioCardDimension,
        cacheHeight: audioCardDimension.toInt(),
        cacheWidth: audioCardDimension.toInt(),
      ),
      onPlay: feedUrl == null
          ? null
          : () => di<PlayAnywhereManager>().command.run(
              PlayAnywhereParam(
                pageId: feedUrl,
                audioPageType: AudioPageType.podcast,
              ),
            ),
      onTap: () {
        if (feedUrl == null || feedUrl.isEmpty) {
          context.toast(Text(context.l10n.podcastFeedIsEmpty));
          return;
        }
        di<RoutingManager>().push(
          builder: (context) => PodcastPage(feedUrl: feedUrl, genre: genre),
          pageId: feedUrl,
        );
      },
    );
  }
}
