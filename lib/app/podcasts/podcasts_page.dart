import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/no_search_result_page.dart';
import 'package:musicpod/app/common/offline_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/connectivity_notifier.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/podcasts/podcast_model.dart';
import 'package:musicpod/app/podcasts/podcast_search_field.dart';
import 'package:musicpod/app/podcasts/podcast_search_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/data/podcast_genre.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/string_x.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastsPage extends StatefulWidget {
  const PodcastsPage({
    super.key,
    this.showWindowControls = true,
  });

  final bool showWindowControls;

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
    final isOnline = context.select((ConnectivityNotifier c) => c.isOnline);
    final model = context.read<PodcastModel>();
    final startPlaylist = context.read<PlayerModel>().startPlaylist;
    final theme = Theme.of(context);
    final podcastSubscribed = context.read<LibraryModel>().podcastSubscribed;
    final removePodcast = context.read<LibraryModel>().removePodcast;
    final addPodcast = context.read<LibraryModel>().addPodcast;
    final textStyle =
        theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w100);
    final buttonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );

    final search = model.search;
    final setSearchQuery = model.setSearchQuery;
    final searchQuery = context.select((PodcastModel m) => m.searchQuery);

    final charts = context.select((PodcastModel m) => m.charts);
    final chartsCount = context.select((PodcastModel m) => m.charts?.length);

    final country = context.select((PodcastModel m) => m.country);
    final sortedCountries =
        context.select((PodcastModel m) => m.sortedCountries);
    context.select((PodcastModel m) => m.country);

    final setCountry = model.setCountry;
    final podcastGenre = context.select((PodcastModel m) => m.podcastGenre);
    final sortedGenres = context.select((PodcastModel m) => m.sortedGenres);
    final setPodcastGenre = model.setPodcastGenre;
    final loadCharts = model.loadCharts;
    final podcastSearchResult =
        context.select((PodcastModel m) => m.podcastSearchResult);

    void onTapText(String text) {
      setSearchQuery(text);
      search(searchQuery: text);
    }

    Widget grid;
    if (charts == null) {
      grid = GridView(
        gridDelegate: kImageGridDelegate,
        padding: kGridPadding,
        children: List.generate(30, (index) => Audio())
            .map((e) => const AudioCard())
            .toList(),
      );
    } else if (charts.isEmpty == true) {
      grid = NoSearchResultPage(
        message: context.l10n.noPodcastChartsFound,
      );
    } else {
      grid = GridView.builder(
        padding: kGridPadding,
        itemCount: chartsCount,
        gridDelegate: kImageGridDelegate,
        itemBuilder: (context, index) {
          final podcast = charts.elementAt(index);
          final name = podcast.firstOrNull?.album ?? '';

          final image = SafeNetworkImage(
            url: podcast.firstOrNull?.albumArtUrl ??
                podcast.firstOrNull?.imageUrl,
            fit: BoxFit.contain,
          );

          return AudioCard(
            image: image,
            onPlay: () {
              startPlaylist(podcast, name);
            },
            onTap: () => _pushNewPodcastPage(
              context,
              podcast,
              podcastSubscribed,
              name,
              onTapText,
              theme,
              removePodcast,
              addPodcast,
            ),
          );
        },
      );
    }

    final controlPanel = Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
      child: Row(
        children: [
          Text(
            searchQuery?.isNotEmpty == true
                ? 'Search:     "${searchQuery!}"'
                : 'Top 10 Charts:',
            style: textStyle,
          ),
          const SizedBox(
            width: 10,
          ),
          if (searchQuery == null || searchQuery.isEmpty)
            YaruPopupMenuButton<PodcastGenre>(
              style: buttonStyle,
              onSelected: (value) {
                setPodcastGenre(value);
                loadCharts();
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
          const SizedBox(
            width: 10,
          ),
          YaruPopupMenuButton<Country>(
            style: buttonStyle,
            onSelected: (value) {
              setCountry(value);
              loadCharts();
            },
            initialValue: country,
            child: Text(
              country.name.capitalize(),
              style: textStyle,
            ),
            itemBuilder: (context) {
              return [
                for (final c in sortedCountries)
                  PopupMenuItem(
                    value: c,
                    child: Text(c.name.capitalize()),
                  )
              ];
            },
          ),
        ],
      ),
    );

    final page = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        controlPanel,
        const Divider(
          height: 0,
        ),
        const SizedBox(
          height: 15,
        ),
        Expanded(child: grid),
      ],
    );

    if (!isOnline) {
      return const OfflinePage();
    } else {
      return Navigator(
        pages: [
          MaterialPage(
            child: YaruDetailPage(
              appBar: YaruWindowTitleBar(
                style: widget.showWindowControls
                    ? YaruTitleBarStyle.normal
                    : YaruTitleBarStyle.undecorated,
                title: const PodcastSearchField(),
              ),
              body: page,
            ),
          ),
          if (searchQuery?.isNotEmpty == true)
            MaterialPage(
              child: YaruDetailPage(
                appBar: YaruWindowTitleBar(
                  style: widget.showWindowControls
                      ? YaruTitleBarStyle.normal
                      : YaruTitleBarStyle.undecorated,
                  title: const PodcastSearchField(),
                  leading: YaruBackButton(
                    style: YaruBackButtonStyle.rounded,
                    onPressed: () {
                      setSearchQuery('');
                      Navigator.maybePop(context);
                    },
                  ),
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    controlPanel,
                    const Divider(
                      height: 0,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: podcastSearchResult == null
                          ? GridView(
                              padding: kGridPadding,
                              gridDelegate: kImageGridDelegate,
                              children: List.generate(
                                30,
                                (index) => const AudioCard(),
                              ).toList(),
                            )
                          : podcastSearchResult.isEmpty
                              ? NoSearchResultPage(
                                  message: context.l10n.noPodcastFound,
                                )
                              : PodcastSearchPage(
                                  showWindowControls: widget.showWindowControls,
                                ),
                    )
                  ],
                ),
              ),
            )
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    }
  }

  void _pushNewPodcastPage(
    BuildContext context,
    Set<Audio> podcast,
    bool Function(String name) podcastSubscribed,
    String name,
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
              : podcastSubscribed(name);

          return AudioPage(
            onAlbumTap: onTapText,
            onArtistTap: onTapText,
            audioPageType: AudioPageType.podcast,
            showWindowControls: widget.showWindowControls,
            sort: false,
            showTrack: false,
            controlPageButton: YaruIconButton(
              icon: Icon(
                YaruIcons.rss,
                color: subscribed ? theme.primaryColor : null,
              ),
              onPressed: subscribed
                  ? () => removePodcast(
                        name,
                      )
                  : () {
                      addPodcast(
                        name,
                        podcast,
                      );
                    },
            ),
            image: ClipRRect(
              borderRadius: BorderRadius.circular(
                10,
              ),
              child: SafeNetworkImage(
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
            ),
            title: const PodcastSearchField(),
            deletable: false,
            editableName: false,
            audios: podcast,
            pageId: podcast.firstOrNull?.album ??
                podcast.firstOrNull?.title ??
                podcast.toString(),
          );
        },
      ),
    );
  }
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
