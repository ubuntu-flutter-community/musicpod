import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../common/data/audio.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../common/view/offline_page.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../podcast_model.dart';
import 'podcasts_collection_body.dart';

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
      di<PodcastModel>().init(
        updateMessage: context.l10n.newEpisodeAvailable,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);
    if (!isOnline) return const OfflinePage();

    final checkingForUpdates =
        watchPropertyValue((PodcastModel m) => m.checkingForUpdates);

    final subsBody = PodcastsCollectionBody(
      loading: checkingForUpdates,
      isOnline: isOnline,
    );

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        titleSpacing: 0,
        adaptive: true,
        actions: [
          Flexible(
            child: Padding(
              padding: appBarSingleActionSpacing,
              child: SearchButton(
                onPressed: () {
                  final searchModel = di<SearchModel>();
                  di<LibraryModel>().pushNamed(kSearchPageId);
                  searchModel
                    ..setAudioType(AudioType.podcast)
                    ..search();
                },
              ),
            ),
          ),
        ],
        title: Text('${context.l10n.podcasts} ${context.l10n.collection}'),
      ),
      body: subsBody,
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
