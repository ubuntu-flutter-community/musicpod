import 'package:flutter/material.dart';

import 'package:podcast_search/podcast_search.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../get.dart';
import '../../player.dart';
import '../../podcasts.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';
import '../settings/settings_model.dart';
import 'podcasts_collection_body.dart';
import 'podcasts_control_panel.dart';
import 'podcasts_discover_grid.dart';
import 'podcasts_page_title.dart';

class PodcastsPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PodcastsPage({super.key});

  @override
  State<PodcastsPage> createState() => _PodcastsPageState();
}

class _PodcastsPageState extends State<PodcastsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final settingsModel = getIt<SettingsModel>();
      final appModel = getIt<AppModel>();

      getIt<PodcastModel>().init(
        countryCode: appModel.countryCode,
        updateMessage: context.l10n.newEpisodeAvailable,
        usePodcastIndex: settingsModel.usePodcastIndex,
        podcastIndexApiKey: settingsModel.podcastIndexApiKey,
        podcastIndexApiSecret: settingsModel.podcastIndexApiSecret,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((AppModel m) => m.isOnline);
    if (!isOnline) return const OfflinePage();

    final model = getIt<PodcastModel>();
    final searchResult = watchPropertyValue((PodcastModel m) => m.searchResult);

    final searchActive = watchPropertyValue((PodcastModel m) => m.searchActive);
    final setSearchActive = model.setSearchActive;
    final theme = context.t;
    final libraryModel = getIt<LibraryModel>();

    final limit = watchPropertyValue((PodcastModel m) => m.limit);
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

    final searchQuery = watchPropertyValue((PodcastModel m) => m.searchQuery);

    final country = watchPropertyValue((PodcastModel m) => m.country);
    final sortedCountries =
        watchPropertyValue((PodcastModel m) => m.sortedCountries);

    final checkingForUpdates =
        watchPropertyValue((PodcastModel m) => m.checkingForUpdates);

    void setCountry(Country? country) {
      model.setCountry(country);
      libraryModel.setLastCountryCode(country?.code);
    }

    final podcastGenre = watchPropertyValue((PodcastModel m) => m.podcastGenre);
    final sortedGenres = watchPropertyValue((PodcastModel m) => m.sortedGenres);
    final setPodcastGenre = model.setPodcastGenre;
    final usePodcastIndex =
        watchPropertyValue((SettingsModel m) => m.usePodcastIndex);

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
      isOnline: isOnline,
    );

    return YaruDetailPage(
      appBar: HeaderBar(
        leading: (Navigator.canPop(context))
            ? NavBackButton(
                onPressed: () {
                  setSearchActive(false);
                },
              )
            : const SizedBox.shrink(),
        titleSpacing: 0,
        adaptive: true,
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
      body: AdaptiveContainer(
        child: searchActive ? searchBody : subsBody,
      ),
    );
  }
}

class PodcastsPageIcon extends StatelessWidget with WatchItMixin {
  const PodcastsPageIcon({
    super.key,
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final audioType = watchPropertyValue((PlayerModel m) => m.audio?.audioType);

    final checkingForUpdates =
        watchPropertyValue((PodcastModel m) => m.checkingForUpdates);

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
