import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/podcasts/podcast_model.dart';
import 'package:musicpod/app/podcasts/podcasts_page.dart';
import 'package:provider/provider.dart';

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
    final searchQuery = context.select((PodcastModel m) => m.searchQuery);

    void onTapText(String text) {
      setSearchQuery(text);
      search(searchQuery: text);
    }

    return GridView.builder(
      itemCount: searchResultCount,
      padding: kGridPadding,
      gridDelegate: kImageGridDelegate,
      itemBuilder: (context, index) {
        if (searchResultCount == 0) {
          return const AudioCard();
        }
        final podcast = searchResult!.elementAt(index);
        return AudioCard(
          image: SafeNetworkImage(
            url: podcast.firstOrNull?.albumArtUrl ??
                podcast.firstOrNull?.imageUrl,
            fit: BoxFit.contain,
          ),
          onPlay: podcast.firstOrNull?.album == null
              ? null
              : () {
                  startPlaylist(podcast, podcast.firstOrNull?.album ?? '');
                },
          onTap: () {
            pushPodcastPage(
              context: context,
              podcast: podcast,
              podcastSubscribed: podcastSubscribed,
              onTapText: onTapText,
              theme: theme,
              removePodcast: removePodcast,
              addPodcast: addPodcast,
              setSearchQuery: setSearchQuery,
              searchQuery: searchQuery,
              search: search,
              showWindowControls: showWindowControls,
            );
          },
        );
      },
    );
  }
}
