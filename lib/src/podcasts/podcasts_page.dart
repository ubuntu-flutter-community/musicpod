import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../player.dart';
import '../../podcasts.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';
import '../settings/settings_model.dart';
import 'podcasts_collection_body.dart';
import 'podcasts_control_panel.dart';
import 'podcasts_discover_grid.dart';
import 'podcasts_page_title.dart';

class PodcastsPage extends ConsumerStatefulWidget {
  const PodcastsPage({
    super.key,
    required this.isOnline,
    this.countryCode,
  });

  final bool isOnline;
  final String? countryCode;

  @override
  ConsumerState<PodcastsPage> createState() => _PodcastsPageState();
}

class _PodcastsPageState extends ConsumerState<PodcastsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final settingsModel = ref.read(settingsModelProvider);
      ref.read(podcastModelProvider).init(
            countryCode: widget.countryCode,
            updateMessage: context.l10n.newEpisodeAvailable,
            isOnline: widget.isOnline,
            usePodcastIndex: settingsModel.usePodcastIndex,
            podcastIndexApiKey: settingsModel.podcastIndexApiKey,
            podcastIndexApiSecret: settingsModel.podcastIndexApiSecret,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOnline) {
      return const OfflinePage();
    }

    final model = ref.read(podcastModelProvider);
    final searchResult =
        ref.watch(podcastModelProvider.select((m) => m.searchResult));

    final searchActive =
        ref.watch(podcastModelProvider.select((m) => m.searchActive));
    final setSearchActive = model.setSearchActive;
    final theme = context.t;
    final libraryModel = ref.read(libraryModelProvider);

    final limit = ref.watch(podcastModelProvider.select((m) => m.limit));
    final setLimit = model.setLimit;

    final search = model.search;
    final setSearchQuery = model.setSearchQuery;
    final textStyle =
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    final buttonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );

    final searchQuery =
        ref.watch(podcastModelProvider.select((m) => m.searchQuery));

    final country = ref.watch(podcastModelProvider.select((m) => m.country));
    final sortedCountries =
        ref.watch(podcastModelProvider.select((m) => m.sortedCountries));

    final checkingForUpdates =
        ref.watch(podcastModelProvider.select((m) => m.checkingForUpdates));

    void setCountry(Country? country) {
      model.setCountry(country);
      libraryModel.setLastCountryCode(country?.code);
    }

    final podcastGenre =
        ref.watch(podcastModelProvider.select((m) => m.podcastGenre));
    final sortedGenres =
        ref.watch(podcastModelProvider.select((m) => m.sortedGenres));
    final setPodcastGenre = model.setPodcastGenre;
    final usePodcastIndex =
        ref.watch(settingsModelProvider.select((m) => m.usePodcastIndex));

    final showWindowControls =
        ref.watch(appModelProvider.select((m) => m.showWindowControls));

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
      sortedGenres: usePodcastIndex
          ? sortedGenres
              .where((e) => !e.name.contains('XXXITunesOnly'))
              .toList()
          : sortedGenres
              .where((e) => !e.name.contains('XXXPodcastIndexOnly'))
              .toList(),
    );

    final searchBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        controlPanel,
        const SizedBox(
          height: 15,
        ),
        Expanded(
          child: PodcastsDiscoverGrid(
            searchResult: searchResult,
            checkingForUpdates: checkingForUpdates,
            limit: limit,
            incrementLimit: () async {
              setLimit(limit + 20);
              await search();
            },
          ),
        ),
      ],
    );

    final subsBody = PodcastsCollectionBody(
      loading: checkingForUpdates,
      isOnline: widget.isOnline,
    );

    return Scaffold(
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
          Flexible(
            child: Padding(
              padding: appBarActionSpacing,
              child: SearchButton(
                active: searchActive,
                onPressed: () => setSearchActive(!searchActive),
              ),
            ),
          ),
        ],
        title: searchActive
            ? PodcastsPageTitle(
                searchQuery: searchQuery,
                setSearchQuery: setSearchQuery,
                search: search,
              )
            : Text('${context.l10n.podcasts} ${context.l10n.collection}'),
      ),
      body: Padding(
        padding: tabViewPadding,
        child: searchActive ? searchBody : subsBody,
      ),
    );
  }
}

class PodcastsPageIcon extends ConsumerWidget {
  const PodcastsPageIcon({
    super.key,
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.t;
    final audioType =
        ref.watch(playerModelProvider.select((m) => m.audio?.audioType));

    final checkingForUpdates =
        ref.watch(podcastModelProvider.select((m) => m.checkingForUpdates));

    if (checkingForUpdates) {
      return const SideBarProgress();
    }

    if (audioType == AudioType.podcast) {
      return Icon(
        Iconz().play,
        color: theme.colorScheme.primary,
      );
    }

    return Padding(
      padding: kMainPageIconPadding,
      child: selected ? Icon(Iconz().podcastFilled) : Icon(Iconz().podcast),
    );
  }
}
