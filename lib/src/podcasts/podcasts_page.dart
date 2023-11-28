import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../data.dart';
import '../../player.dart';
import '../../podcasts.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';
import 'podcasts_collection_body.dart';
import 'podcasts_control_panel.dart';
import 'podcasts_discover_grid.dart';
import 'podcasts_page_title.dart';

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
            isOnline: widget.isOnline,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOnline) {
      return const OfflinePage();
    }

    final model = context.read<PodcastModel>();
    final searchActive = context.select((PodcastModel m) => m.searchActive);
    final setSearchActive = model.setSearchActive;
    final startPlaylist = context.read<PlayerModel>().startPlaylist;
    final theme = Theme.of(context);
    final libraryModel = context.read<LibraryModel>();
    final podcastSubscribed = libraryModel.podcastSubscribed;
    final removePodcast = libraryModel.removePodcast;
    final addPodcast = libraryModel.addPodcast;
    final setPodcastIndex = libraryModel.setPodcastIndex;
    final podcastIndex = context.select((LibraryModel m) => m.podcastIndex);

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

    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    void onTapText(String text) {
      setSearchQuery(text);
      search(searchQuery: text);
    }

    Widget grid;
    if (searchResult == null) {
      grid = GridView(
        gridDelegate: imageGridDelegate,
        padding: gridPadding,
        children: List.generate(limit, (index) => Audio())
            .map(
              (e) => const AudioCard(
                bottom: AudioCardBottom(),
              ),
            )
            .toList(),
      );
    } else if (searchResult.items.isEmpty == true) {
      grid = NoSearchResultPage(message: Text(context.l10n.noPodcastFound));
    } else {
      grid = PodcastsDiscoverGrid(
        searchResult: searchResult,
        startPlaylist: startPlaylist,
        podcastSubscribed: podcastSubscribed,
        removePodcast: removePodcast,
        addPodcast: addPodcast,
        setSelectedFeedUrl: setSelectedFeedUrl,
        selectedFeedUrl: selectedFeedUrl,
        onTapText: onTapText,
      );
    }

    final controlPanel = PodcastsControlPanel(
      limit: limit,
      setLimit: setLimit,
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

    final searchBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        controlPanel,
        const SizedBox(
          height: 15,
        ),
        Expanded(child: grid),
      ],
    );

    final subsBody = PodcastsCollectionBody(
      isOnline: widget.isOnline,
      startPlaylist: startPlaylist,
      onTapText: onTapText,
      addPodcast: addPodcast,
      removePodcast: removePodcast,
    );

    return DefaultTabController(
      initialIndex: podcastIndex ?? 1,
      length: 2,
      child: Scaffold(
        appBar: HeaderBar(
          leading: (Navigator.canPop(context))
              ? NavBackButton(
                  onPressed: () {
                    setSearchActive(false);
                  },
                )
              : const SizedBox.shrink(),
          titleSpacing: 0,
          style: showWindowControls
              ? YaruTitleBarStyle.normal
              : YaruTitleBarStyle.undecorated,
          actions: [
            Padding(
              padding: appBarActionSpacing,
              child: SearchButton(
                active: searchActive,
                onPressed: () => setSearchActive(!searchActive),
              ),
            ),
          ],
          title: PodcastsPageTitle(
            onIndexSelected: setPodcastIndex,
            searchActive: searchActive,
            searchQuery: searchQuery,
            setSearchActive: setSearchActive,
            setSearchQuery: setSearchQuery,
            search: search,
          ),
        ),
        body: Padding(
          padding: tabViewPadding,
          child: TabBarView(
            children: [
              subsBody,
              searchBody,
            ],
          ),
        ),
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
    final checkingForUpdates =
        context.select((PodcastModel m) => m.checkingForUpdates);

    if (checkingForUpdates) {
      return const SideBarProgress();
    }

    if (isPlaying) {
      return Icon(
        Iconz().play,
        color: theme.colorScheme.primary,
      );
    }

    return selected ? Icon(Iconz().podcastFilled) : Icon(Iconz().podcast);
  }
}
