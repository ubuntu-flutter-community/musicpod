import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../podcasts/podcast_model.dart';
import '../../podcasts/view/podcast_snackbar_contents.dart';
import '../search_model.dart';

class SliverPodcastSearchResults extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const SliverPodcastSearchResults({super.key});

  @override
  State<SliverPodcastSearchResults> createState() =>
      _SliverPodcastSearchResultsState();
}

class _SliverPodcastSearchResultsState
    extends State<SliverPodcastSearchResults> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    di<PodcastModel>()
        .init(
          updateMessage: context.l10n.newEpisodeAvailable,
        )
        .then((_) => di<SearchModel>().search());
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);

    if (!isOnline) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: OfflineBody(),
      );
    }

    final loading = watchPropertyValue((SearchModel m) => m.loading);

    final searchResultItems =
        watchPropertyValue((SearchModel m) => m.podcastSearchResult?.items);

    if (searchResultItems == null || searchResultItems.isEmpty) {
      return SliverFillNoSearchResultPage(
        icon: loading
            ? const SizedBox.shrink()
            : searchResultItems == null
                ? const AnimatedEmoji(AnimatedEmojis.drum)
                : const AnimatedEmoji(AnimatedEmojis.babyChick),
        message: loading
            ? const Progress()
            : Text(
                searchResultItems == null
                    ? context.l10n.search
                    : context.l10n.noPodcastFound,
              ),
      );
    }

    final loadingFeed = watchPropertyValue((PodcastModel m) => m.loadingFeed);
    final libraryModel = di<LibraryModel>();
    final playerModel = di<PlayerModel>();
    final podcastModel = di<PodcastModel>();

    return SliverGrid.builder(
      itemCount: searchResultItems.length,
      gridDelegate: audioCardGridDelegate,
      itemBuilder: (context, index) {
        final podcastItem = searchResultItems.elementAt(index);

        final art = podcastItem.artworkUrl600 ?? podcastItem.artworkUrl;
        final image = SafeNetworkImage(
          url: art,
          fit: BoxFit.cover,
          height: audioCardDimension,
          width: audioCardDimension,
        );

        final feedUrl = podcastItem.feedUrl;

        void loadPodcast({required bool play}) {
          if (feedUrl == null) {
            showSnackBar(
              context: context,
              content: const PodcastSearchEmptyFeedSnackBarContent(),
            );
          } else {
            podcastModel.loadPodcast(
              context: context,
              feedUrl: feedUrl,
              itemImageUrl: art,
              genre: podcastItem.primaryGenreName,
              playerModel: play ? playerModel : null,
              libraryModel: libraryModel,
            );
          }
        }

        return AudioCard(
          key: ValueKey(feedUrl),
          bottom: AudioCardBottom(
            text: podcastItem.collectionName ?? podcastItem.trackName,
          ),
          image: image,
          onPlay: loadingFeed ? null : () => loadPodcast(play: true),
          onTap: loadingFeed ? null : () => loadPodcast(play: false),
        );
      },
    );
  }
}
