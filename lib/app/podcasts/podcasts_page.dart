import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/app_model.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/country_popup.dart';
import 'package:musicpod/app/common/no_search_result_page.dart';
import 'package:musicpod/app/common/offline_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/common/search_button.dart';
import 'package:musicpod/app/common/search_field.dart';
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
  });

  final bool isOnline;

  @override
  State<PodcastsPage> createState() => _PodcastsPageState();
}

class _PodcastsPageState extends State<PodcastsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final code = WidgetsBinding.instance.platformDispatcher.locale.countryCode
          ?.toLowerCase();
      context.read<PodcastModel>().init(
            countryCode: code,
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
    final podcastSubscribed = context.read<LibraryModel>().podcastSubscribed;
    final removePodcast = context.read<LibraryModel>().removePodcast;
    final addPodcast = context.read<LibraryModel>().addPodcast;

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
            onTap: () => pushPodcastPage(
              context: context,
              podcastItem: podcast,
              podcastSubscribed: podcastSubscribed,
              onTapText: onTapText,
              removePodcast: removePodcast,
              addPodcast: addPodcast,
            ),
          );
        },
      );
    }

    final controlPanel = _PodcastsControlPanel(
      search: search,
      searchQuery: searchQuery,
      setCountry: setCountry,
      country: country,
      sortedCountries: sortedCountries,
      buttonStyle: buttonStyle,
      setPodcastGenre: setPodcastGenre,
      podcastGenre: podcastGenre,
      textStyle: textStyle,
      sortedGenres: sortedGenres,
    );

    if (!widget.isOnline) {
      return const OfflinePage();
    } else {
      return YaruDetailPage(
        backgroundColor: light ? kBackGroundLight : kBackgroundDark,
        appBar: YaruWindowTitleBar(
          backgroundColor: Colors.transparent,
          leading: SearchButton(
            searchActive: searchActive,
            setSearchActive: setSearchActive,
          ),
          titleSpacing: 0,
          style: showWindowControls
              ? YaruTitleBarStyle.normal
              : YaruTitleBarStyle.undecorated,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (searchActive)
                Expanded(
                  child: SearchField(
                    onClear: () {
                      setSearchActive(false);
                      setSearchQuery('');
                      search();
                    },
                    key: ValueKey(searchQuery),
                    text: searchQuery,
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
              controlPanel,
              const SizedBox(width: 10)
            ],
          ),
        ),
        body: grid,
      );
    }
  }
}

class _PodcastsControlPanel extends StatelessWidget {
  const _PodcastsControlPanel({
    required this.searchQuery,
    required this.setCountry,
    required this.country,
    required this.sortedCountries,
    required this.buttonStyle,
    required this.setPodcastGenre,
    required this.podcastGenre,
    required this.textStyle,
    required this.sortedGenres,
    required this.search,
  });

  final String? searchQuery;
  final void Function(Country? value) setCountry;
  final void Function({String? searchQuery}) search;
  final Country? country;
  final List<Country> sortedCountries;
  final ButtonStyle buttonStyle;
  final void Function(PodcastGenre value) setPodcastGenre;
  final PodcastGenre podcastGenre;
  final TextStyle? textStyle;
  final List<PodcastGenre> sortedGenres;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kHeaderBarItemHeight,
      child: Row(
        children: [
          CountryPopup(
            onSelected: (value) {
              setCountry(value);
              search(searchQuery: searchQuery);
            },
            value: country,
            countries: sortedCountries,
          ),
          const SizedBox(
            width: 5,
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
          ),
        ],
      ),
    );
  }
}

Future<void> pushPodcastPage({
  required BuildContext context,
  required Item podcastItem,
  required bool Function(String name) podcastSubscribed,
  required void Function(String text) onTapText,
  required void Function(String name) removePodcast,
  required void Function(String name, Set<Audio> audios) addPodcast,
}) async {
  if (podcastItem.feedUrl == null) return;

  await findEpisodes(url: podcastItem.feedUrl!).then((podcast) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final subscribed = podcast.firstOrNull?.album == null
              ? false
              : podcastSubscribed(
                  podcast.first.album!,
                );

          final id = podcastItem.collectionName ?? podcast.toString();

          return PodcastPage(
            subscribed: subscribed,
            imageUrl: podcastItem.artworkUrl600,
            addPodcast: addPodcast,
            removePodcast: removePodcast,
            onAlbumTap: onTapText,
            onArtistTap: onTapText,
            audios: podcast,
            pageId: id,
          );
        },
      ),
    );
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
