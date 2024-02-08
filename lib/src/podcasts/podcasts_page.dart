import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../player.dart';
import '../../podcasts.dart';
import '../l10n/l10n.dart';
import '../settings/settings_service.dart';
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
      final settingsModel = getService<SettingsService>();
      context.read<PodcastModel>().init(
            countryCode: widget.countryCode,
            updateMessage: context.l10n.newEpisodeAvailable,
            isOnline: widget.isOnline,
            usePodcastIndex: settingsModel.usePodcastIndex.value,
            podcastIndexApiKey: settingsModel.podcastIndexApiKey.value,
            podcastIndexApiSecret: settingsModel.podcastIndexApiSecret.value,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOnline) {
      return const OfflinePage();
    }

    final model = context.read<PodcastModel>();
    final searchResult = context.select((PodcastModel m) => m.searchResult);

    final searchActive = context.select((PodcastModel m) => m.searchActive);
    final setSearchActive = model.setSearchActive;
    final theme = context.t;

    final limit = context.select((PodcastModel m) => m.limit);
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

    final searchQuery = context.select((PodcastModel m) => m.searchQuery);

    final country = context.select((PodcastModel m) => m.country);
    final sortedCountries =
        context.select((PodcastModel m) => m.sortedCountries);
    context.select((PodcastModel m) => m.country);

    final checkingForUpdates =
        context.select((PodcastModel m) => m.checkingForUpdates);
    final appStateService = getService<AppStateService>();
    final settingsService = getService<SettingsService>();
    final showWindowControls = appStateService.showWindowControls;
    void setCountry(Country? country) {
      model.setCountry(country);
      appStateService.setLastCountryCode(country?.code);
    }

    final podcastGenre = context.select((PodcastModel m) => m.podcastGenre);
    final sortedGenres = context.select((PodcastModel m) => m.sortedGenres);
    final setPodcastGenre = model.setPodcastGenre;
    final usePodcastIndex = settingsService.usePodcastIndex;

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
      sortedGenres: usePodcastIndex.watch(context)
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
        style: showWindowControls.watch(context)
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

class PodcastsPageIcon extends StatelessWidget {
  const PodcastsPageIcon({
    super.key,
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final audioType = context.select((PlayerModel m) => m.audio?.audioType);

    final checkingForUpdates =
        context.select((PodcastModel m) => m.checkingForUpdates);

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
