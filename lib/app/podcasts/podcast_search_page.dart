import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/no_search_result_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/podcasts/podcasts_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:yaru_icons/yaru_icons.dart';

class PodcastSearchPage extends StatelessWidget {
  const PodcastSearchPage({
    super.key,
    required this.showWindowControls,
    this.searchResult,
    this.searchResultCount,
    required this.startPlaylist,
    required this.podcastSubscribed,
    required this.removePodcast,
    required this.addPodcast,
    required this.search,
    required this.setSearchQuery,
    required this.setSearchActive,
  });

  final bool showWindowControls;
  final List<Item>? searchResult;
  final int? searchResultCount;
  final Future<void> Function(Set<Audio>, String) startPlaylist;
  final bool Function(String) podcastSubscribed;
  final void Function(String) removePodcast;
  final void Function(String, Set<Audio>) addPodcast;
  final void Function({String? searchQuery}) search;
  final void Function(String?) setSearchQuery;
  final void Function(bool) setSearchActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void onTapText(String text) {
      setSearchQuery(text);
      search(searchQuery: text);
      setSearchActive(true);
    }

    if (searchResult?.isEmpty == true) {
      return NoSearchResultPage(
        message: context.l10n.noPodcastFound,
      );
    }

    return GridView.builder(
      itemCount: searchResultCount,
      padding: kPodcastGridPadding,
      gridDelegate: kImageGridDelegate,
      itemBuilder: (context, index) {
        if (searchResultCount == 0) {
          return const AudioCard();
        }
        final podcast = searchResult!.elementAt(index);
        return AudioCard(
          image: SafeNetworkImage(
            url: podcast.artworkUrl600,
            fit: BoxFit.contain,
            fallBackIcon: Icon(
              YaruIcons.podcast,
              size: 70,
              color: theme.hintColor,
            ),
          ),
          onPlay: () async {
            if (podcast.feedUrl == null) return;
            final feed = await findEpisodes(url: podcast.feedUrl!);
            startPlaylist(feed, podcast.collectionName!);
          },
          onTap: () {
            pushPodcastPage(
              context: context,
              podcastItem: podcast,
              podcastSubscribed: podcastSubscribed,
              onTapText: onTapText,
              removePodcast: removePodcast,
              addPodcast: addPodcast,
              showWindowControls: showWindowControls,
            );
          },
        );
      },
    );
  }
}
