import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/podcasts/podcast_model.dart';
import 'package:musicpod/app/podcasts/podcast_search_field.dart';
import 'package:musicpod/data/audio.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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
    final light = theme.brightness == Brightness.light;
    final search = model.search;
    final setSearchQuery = model.setSearchQuery;

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
            fallBackIcon: Shimmer.fromColors(
              baseColor: light ? kShimmerBaseLight : kShimmerBaseDark,
              highlightColor:
                  light ? kShimmerHighLightLight : kShimmerHighLightDark,
              child: YaruBorderContainer(
                color: light ? kShimmerBaseLight : kShimmerBaseDark,
                height: 250,
                width: 250,
              ),
            ),
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
            _pushPodcastPage(
              context,
              podcast,
              podcastSubscribed,
              onTapText,
              theme,
              removePodcast,
              addPodcast,
            );
          },
        );
      },
    );
  }

  void _pushPodcastPage(
    BuildContext context,
    Set<Audio> podcast,
    bool Function(String name) podcastSubscribed,
    void Function(String text) onTapText,
    ThemeData theme,
    void Function(String name) removePodcast,
    void Function(String name, Set<Audio> audios) addPodcast,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final subscribed = podcast.firstOrNull?.album == null
              ? false
              : podcastSubscribed(
                  podcast.first.album!,
                );
          return AudioPage(
            onAlbumTap: onTapText,
            onArtistTap: onTapText,
            audioPageType: AudioPageType.podcast,
            showWindowControls: showWindowControls,
            sort: false,
            showTrack: false,
            image: SafeNetworkImage(
              fallBackIcon: SizedBox(
                width: 200,
                child: Center(
                  child: Icon(
                    YaruIcons.music_note,
                    size: 80,
                    color: theme.hintColor,
                  ),
                ),
              ),
              url: podcast.firstOrNull?.albumArtUrl ??
                  podcast.firstOrNull?.imageUrl,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.medium,
            ),
            controlPageButton: subscribed
                ? YaruIconButton(
                    icon: Icon(
                      YaruIcons.rss,
                      color: theme.primaryColor,
                    ),
                    onPressed: podcast.firstOrNull?.album == null
                        ? null
                        : () => removePodcast(
                              podcast.first.album!,
                            ),
                  )
                : YaruIconButton(
                    icon: const Icon(
                      YaruIcons.rss,
                    ),
                    onPressed: podcast.firstOrNull?.album == null
                        ? null
                        : () {
                            addPodcast(
                              podcast.first.album!,
                              podcast,
                            );
                          },
                  ),
            title: const PodcastSearchField(),
            deletable: false,
            editableName: false,
            audios: podcast,
            pageId: podcast.firstOrNull?.album ?? podcast.toString(),
          );
        },
      ),
    );
  }
}
