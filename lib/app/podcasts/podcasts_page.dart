import 'package:flutter/material.dart';
import 'package:musicpod/app/app_model.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/constants.dart';
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
import 'package:musicpod/string_x.dart';
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
        context.select((PodcastModel m) => m.searchResult?.resultCount);

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
    } else if (searchResult.items.isEmpty == true) {
      final noResultMessage = searchResult.lastError.isEmpty
          ? context.l10n.noPodcastChartsFound
          : (searchResult.lastError.contains('RangeError')
              ? '${context.l10n.decreaseSearchLimit} ${country?.name.capitalize()}'
              : searchResult.lastError);

      grid = NoSearchResultPage(message: noResultMessage);
    } else {
      grid = GridView.builder(
        padding: kPodcastGridPadding,
        itemCount: searchResultCount,
        gridDelegate: kImageGridDelegate,
        itemBuilder: (context, index) {
          final podcastItem = searchResult.items.elementAt(index);

          final artworkUrl600 = podcastItem.artworkUrl600;
          final image = SafeNetworkImage(
            url: artworkUrl600,
            fit: BoxFit.contain,
          );

          return AudioCard(
            image: image,
            onPlay: () {
              if (podcastItem.feedUrl == null) return;
              findEpisodes(
                feedUrl: podcastItem.feedUrl!,
                itemImageUrl: artworkUrl600,
              ).then((feed) {
                if (feed.isNotEmpty) {
                  startPlaylist(feed, podcastItem.feedUrl!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.podcastFeedIsEmpty)),
                  );
                }
              });
            },
            onTap: () async => await pushPodcastPage(
              context: context,
              podcastItem: podcastItem,
              podcastSubscribed: podcastSubscribed,
              onTapText: ({required audioType, required text}) =>
                  onTapText(text),
              removePodcast: removePodcast,
              addPodcast: addPodcast,
              setFeedUrl: setSelectedFeedUrl,
              oldFeedUrl: selectedFeedUrl,
              itemImageUrl: artworkUrl600,
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
        appBar: YaruWindowTitleBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          border: BorderSide.none,
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
  required void Function({
    required String text,
    required AudioType audioType,
  }) onTapText,
  required void Function(String name) removePodcast,
  required void Function(String name, Set<Audio> audios) addPodcast,
  required void Function(String? feedUrl) setFeedUrl,
  required String? oldFeedUrl,
  String? itemImageUrl,
}) async {
  if (podcastItem.feedUrl == null) return;

  setFeedUrl(podcastItem.feedUrl);

  await findEpisodes(feedUrl: podcastItem.feedUrl!, itemImageUrl: itemImageUrl)
      .then((podcast) async {
    if (oldFeedUrl == podcastItem.feedUrl || podcast.isEmpty) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final subscribed = podcastSubscribed(podcastItem.feedUrl);
          final id = podcastItem.feedUrl;

          return PodcastPage(
            subscribed: subscribed,
            imageUrl: podcastItem.artworkUrl600,
            addPodcast: addPodcast,
            removePodcast: removePodcast,
            onTextTap: onTapText,
            audios: podcast,
            pageId: id!,
            title: podcast.firstOrNull?.album ??
                podcast.firstOrNull?.title ??
                podcastItem.feedUrl!,
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
