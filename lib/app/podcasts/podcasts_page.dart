import 'package:flutter/material.dart';
import 'package:musicpod/app/app_model.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/country_popup.dart';
import 'package:musicpod/app/common/limit_popup.dart';
import 'package:musicpod/app/common/no_search_result_page.dart';
import 'package:musicpod/app/common/offline_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/podcasts/podcast_model.dart';
import 'package:musicpod/app/podcasts/podcast_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/data/podcast_genre.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastsPage extends StatefulWidget {
  const PodcastsPage({
    super.key,
    required this.isOnline,
    this.countryCode,
  });

  final bool isOnline;
  final String? countryCode;

  @override
  State<PodcastsPage> createState() => _PodcastsPageState();
}

class _PodcastsPageState extends State<PodcastsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<PodcastModel>().init(
            countryCode: widget.countryCode,
            updateMessage: context.l10n.newEpisodeAvailable,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<PodcastModel>();
    final searchActive = context.select((PodcastModel m) => m.searchActive);
    final setSearchActive = model.setSearchActive;
    final startPlaylist = context.read<PlayerModel>().startPlaylist;
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final libraryModel = context.read<LibraryModel>();
    final podcastSubscribed = libraryModel.podcastSubscribed;
    final removePodcast = libraryModel.removePodcast;
    final addPodcast = libraryModel.addPodcast;
    final setLimit = model.setLimit;
    final setSelectedFeedUrl = model.setSelectedFeedUrl;
    final selectedFeedUrl =
        context.select((PodcastModel m) => m.selectedFeedUrl);
    final limit = context.select((PodcastModel m) => m.limit);

    final search = model.search;
    final setSearchQuery = model.setSearchQuery;
    final textStyle =
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    final buttonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );

    final searchQuery = context.select((PodcastModel m) => m.searchQuery);

    final country = context.select((PodcastModel m) => m.country);
    final sortedCountries =
        context.select((PodcastModel m) => m.sortedCountries);
    context.select((PodcastModel m) => m.country);

    final setCountry = model.setCountry;
    final podcastGenre = context.select((PodcastModel m) => m.podcastGenre);
    final sortedGenres = context.select((PodcastModel m) => m.sortedGenres);
    final setPodcastGenre = model.setPodcastGenre;
    final searchResult = context.select((PodcastModel m) => m.searchResult);
    final searchResultCount =
        context.select((PodcastModel m) => m.searchResult?.length);

    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    void onTapText(String text) {
      setSearchQuery(text);
      search(searchQuery: text);
    }

    Widget grid;
    if (searchResult == null) {
      grid = GridView(
        gridDelegate: kImageGridDelegate,
        padding: kPodcastGridPadding,
        children: List.generate(30, (index) => Audio())
            .map((e) => const AudioCard())
            .toList(),
      );
    } else if (searchResult.isEmpty == true) {
      grid = NoSearchResultPage(
        message: context.l10n.noPodcastChartsFound,
      );
    } else {
      grid = GridView.builder(
        padding: kPodcastGridPadding,
        itemCount: searchResultCount,
        gridDelegate: kImageGridDelegate,
        itemBuilder: (context, index) {
          final podcast = searchResult.elementAt(index);

          final image = SafeNetworkImage(
            url: podcast.artworkUrl600,
            fit: BoxFit.contain,
          );

          return AudioCard(
            image: image,
            onPlay: () async {
              if (podcast.feedUrl == null) return;
              final feed = await findEpisodes(url: podcast.feedUrl!);
              startPlaylist(feed, podcast.collectionName!);
            },
            onTap: () async => await pushPodcastPage(
              context: context,
              podcastItem: podcast,
              podcastSubscribed: podcastSubscribed,
              onTapText: onTapText,
              removePodcast: removePodcast,
              addPodcast: addPodcast,
              setFeedUrl: setSelectedFeedUrl,
              oldFeedUrl: selectedFeedUrl,
            ),
          );
        },
      );
    }

    final controlPanel = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: kHeaderBarItemHeight,
        child: Row(
          children: [
            LimitPopup(
              value: limit,
              onSelected: (value) {
                setLimit(value);
                search(searchQuery: searchQuery);
              },
            ),
            CountryPopup(
              onSelected: (value) {
                setCountry(value);
                search(searchQuery: searchQuery);
              },
              value: country,
              countries: sortedCountries,
            ),
            YaruPopupMenuButton<PodcastGenre>(
              style: buttonStyle,
              onSelected: (value) {
                setPodcastGenre(value);
                search(searchQuery: searchQuery);
              },
              initialValue: podcastGenre,
              child: Text(
                podcastGenre.localize(context.l10n),
                style: textStyle,
              ),
              itemBuilder: (context) {
                return [
                  for (final genre in sortedGenres)
                    PopupMenuItem(
                      value: genre,
                      child: Text(genre.localize(context.l10n)),
                    )
                ];
              },
            )
          ],
        ),
      ),
    );

    if (!widget.isOnline) {
      return const OfflinePage();
    } else {
      return YaruDetailPage(
        backgroundColor: light ? kBackGroundLight : kBackgroundDark,
        appBar: YaruWindowTitleBar(
          backgroundColor: Colors.transparent,
          leading: (Navigator.canPop(context))
              ? const YaruBackButton(
                  style: YaruBackButtonStyle.rounded,
                )
              : const SizedBox.shrink(),
          titleSpacing: 0,
          style: showWindowControls
              ? YaruTitleBarStyle.normal
              : YaruTitleBarStyle.undecorated,
          title: Padding(
            padding: const EdgeInsets.only(right: 40),
            child: YaruSearchTitleField(
              key: ValueKey(searchQuery),
              text: searchQuery,
              alignment: Alignment.center,
              width: kSearchBarWidth,
              searchActive: searchActive,
              title: controlPanel,
              onSearchActive: () => setSearchActive(!searchActive),
              onClear: () {
                setSearchActive(false);
                setSearchQuery('');
                search();
              },
              onSubmitted: (value) {
                setSearchQuery(value);

                if (value?.isEmpty == true) {
                  search();
                } else {
                  search(searchQuery: value);
                }
              },
            ),
          ),
        ),
        body: grid,
      );
    }
  }
}

Future<void> pushPodcastPage({
  required BuildContext context,
  required Item podcastItem,
  required bool Function(String? name) podcastSubscribed,
  required void Function(String text) onTapText,
  required void Function(String name) removePodcast,
  required void Function(String name, Set<Audio> audios) addPodcast,
  required void Function(String? feedUrl) setFeedUrl,
  required String? oldFeedUrl,
}) async {
  if (podcastItem.feedUrl == null) return;

  setFeedUrl(podcastItem.feedUrl);

  await findEpisodes(url: podcastItem.feedUrl!).then((podcast) async {
    if (oldFeedUrl == podcastItem.feedUrl) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final subscribed = podcastSubscribed(podcast.first.album);
          final id = podcastItem.collectionName ?? podcast.toString();

          return PodcastPage(
            subscribed: subscribed,
            imageUrl: podcastItem.artworkUrl600,
            addPodcast: addPodcast,
            removePodcast: removePodcast,
            onAlbumTap: (v) {
              onTapText(v);
              Navigator.of(context).maybePop();
            },
            onArtistTap: (v) {
              onTapText(v);
              Navigator.of(context).maybePop();
            },
            audios: podcast,
            pageId: id,
          );
        },
      ),
    ).then((_) => setFeedUrl(null));
  });
}

class PodcastsPageIcon extends StatelessWidget {
  const PodcastsPageIcon({
    super.key,
    required this.isPlaying,
    required this.selected,
  });

  final bool isPlaying, selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isPlaying) {
      return Icon(
        YaruIcons.media_play,
        color: theme.primaryColor,
      );
    }

    return selected
        ? const Icon(YaruIcons.podcast_filled)
        : const Icon(YaruIcons.podcast);
  }
}
