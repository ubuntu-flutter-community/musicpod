import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/no_search_result_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/podcasts/podcast_model.dart';
import 'package:musicpod/app/podcasts/podcasts_page.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';

class PodcastSearchPage extends StatelessWidget {
  const PodcastSearchPage({super.key, required this.showWindowControls});

  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    final model = context.read<PodcastModel>();
    final searchResult =
        context.select((PodcastModel m) => m.podcastSearchResult);
    final searchResultCount =
        context.select((PodcastModel m) => m.podcastSearchResult?.length);
    final startPlaylist = context.read<PlayerModel>().startPlaylist;
    final theme = Theme.of(context);
    final podcastSubscribed = context.read<LibraryModel>().podcastSubscribed;
    final removePodcast = context.read<LibraryModel>().removePodcast;
    final addPodcast = context.read<LibraryModel>().addPodcast;
    final search = model.search;
    final setSearchQuery = model.setSearchQuery;
    final setSearchActive = model.setSearchActive;

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
