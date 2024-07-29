import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../podcasts/podcast_utils.dart';
import '../search_model.dart';

class SliverPodcastSearchResults extends StatelessWidget with WatchItMixin {
  const SliverPodcastSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);

    if (!isOnline) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: OfflineBody(),
      );
    }

    final searchResultItems =
        watchPropertyValue((SearchModel m) => m.podcastSearchResult?.items);

    if (searchResultItems == null || searchResultItems.isEmpty) {
      return SliverFillNoSearchResultPage(
        icon: searchResultItems == null
            ? const AnimatedEmoji(AnimatedEmojis.drum)
            : const AnimatedEmoji(AnimatedEmojis.babyChick),
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
        final podcastItem = searchResultItems.elementAt(index);

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
    );
  }
}
