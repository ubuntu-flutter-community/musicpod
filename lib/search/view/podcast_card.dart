import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../podcasts/podcast_model.dart';
import '../../podcasts/podcast_search_state.dart';
import '../../podcasts/view/podcast_page.dart';
import '../../podcasts/view/podcast_snackbar_contents.dart';
import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:watch_it/watch_it.dart';

class PodcastCard extends StatelessWidget with WatchItMixin {
  const PodcastCard({super.key, required this.podcastItem});

  final Item podcastItem;

  @override
  Widget build(BuildContext context) {
    final loadingFeed = watchPropertyValue(
      (PodcastModel m) => m.lastState != PodcastSearchState.done,
    );
    final libraryModel = di<LibraryModel>();
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
        if (libraryModel.isPageInLibrary(feedUrl)) {
          libraryModel.push(pageId: feedUrl);
        } else {
          di<PodcastModel>().loadPodcast(
            feedUrl: feedUrl,
            itemImageUrl: art,
            genre: podcastItem.primaryGenreName,
            onFind: (podcast) {
              if (play) {
                di<PlayerModel>().startPlaylist(
                  listName: feedUrl,
                  audios: podcast,
                );
              } else {
                libraryModel.push(
                  builder: (_) => PodcastPage(
                    imageUrl: art ?? podcast.firstOrNull?.imageUrl,
                    preFetchedEpisodes: podcast,
                    feedUrl: feedUrl,
                    title: podcast.firstOrNull?.album ??
                        podcast.firstOrNull?.title ??
                        feedUrl,
                  ),
                  pageId: feedUrl,
                );
              }
            },
          );
        }
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
  }
}
