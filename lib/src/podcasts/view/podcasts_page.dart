import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../../app.dart';
import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../constants.dart';
import '../../../data.dart';
import '../../../get.dart';
import '../../../podcasts.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
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
      final appModel = getIt<AppModel>();

      getIt<PodcastModel>().init(
        countryCode: appModel.countryCode,
        updateMessage: context.l10n.newEpisodeAvailable,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);
    if (!isOnline) return const OfflinePage();

    final model = getIt<PodcastModel>();

    final searchActive =
        watchPropertyValue((PodcastModel m) => m.searchActive ?? false);
    final setSearchActive = model.setSearchActive;

    final search = model.search;
    final setSearchQuery = model.setSearchQuery;

    final searchQuery = watchPropertyValue((PodcastModel m) => m.searchQuery);
    final checkingForUpdates =
        watchPropertyValue((PodcastModel m) => m.checkingForUpdates);

    final searchBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PodcastsControlPanel(),
        const SizedBox(
          height: 15,
        ),
        Expanded(
          child: PodcastsDiscoverGrid(checkingForUpdates: checkingForUpdates),
        ),
      ],
    );

    final subsBody = PodcastsCollectionBody(
      loading: checkingForUpdates,
      isOnline: isOnline,
    );

    return YaruDetailPage(
      appBar: HeaderBar(
        titleSpacing: 0,
        adaptive: true,
        actions: [
          Flexible(
            child: Padding(
              padding: appBarActionSpacing,
              child: SearchButton(
                active: searchActive,
                onPressed: () => setSearchActive(!(searchActive)),
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
