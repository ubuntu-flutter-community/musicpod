import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/icons.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../player/view/player_view.dart';
import '../../settings/settings_model.dart';
import '../app_model.dart';
import '../connectivity_model.dart';
import 'master_detail_page.dart';

class MusicPodScaffold extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MusicPodScaffold({super.key});

  @override
  State<MusicPodScaffold> createState() => _MusicPodScaffoldState();
}

class _MusicPodScaffoldState extends State<MusicPodScaffold> {
  @override
  void initState() {
    super.initState();
    final settingsModel = di<SettingsModel>();
    final appModel = di<AppModel>();
    appModel
        .checkForUpdate(di<ConnectivityModel>().isOnline, context)
        .then((_) {
      if (!mounted) return;
      if (settingsModel.recentPatchNotesDisposed == false) {
        showPatchNotes(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerToTheRight = context.m.size.width > kSideBarThreshHold;
    final isFullScreen = watchPropertyValue((AppModel m) => m.fullWindowMode);

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Expanded(child: MasterDetailPage()),
                  if (!playerToTheRight || isMobile)
                    const PlayerView(mode: PlayerPosition.bottom),
                  if (isMobile && context.m.size.width < 500)
                    const MobileNavigationBar(),
                ],
              ),
            ),
            if (playerToTheRight)
              const SizedBox(
                width: kSideBarPlayerWidth,
                child: PlayerView(mode: PlayerPosition.sideBar),
              ),
          ],
        ),
        if (isFullScreen == true)
          const Scaffold(body: PlayerView(mode: PlayerPosition.fullWindow)),
      ],
    );
  }
}

class MobileNavigationBar extends StatelessWidget with WatchItMixin {
  const MobileNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPageId =
        watchPropertyValue((LibraryModel m) => m.selectedPageId);
    final libraryModel = di<LibraryModel>();

    return NavigationBar(
      height: 60,
      selectedIndex: switch (selectedPageId) {
        kSearchPageId => 0,
        kLocalAudioPageId => 1,
        kRadioPageId => 2,
        _ => 3,
      },
      onDestinationSelected: (i) => libraryModel.pushNamed(
        pageId: switch (i) {
          0 => kSearchPageId,
          1 => kLocalAudioPageId,
          2 => kRadioPageId,
          _ => kPodcastsPageId,
        },
      ),
      destinations: [
        NavigationDestination(
          icon: Icon(Iconz().search),
          selectedIcon: Icon(Iconz().search),
          label: context.l10n.search,
        ),
        NavigationDestination(
          icon: Icon(Iconz().localAudio),
          selectedIcon: Icon(Iconz().localAudioFilled),
          label: context.l10n.localAudio,
        ),
        NavigationDestination(
          icon: Icon(Iconz().radio),
          selectedIcon: Icon(Iconz().radioFilled),
          label: context.l10n.radio,
        ),
        NavigationDestination(
          icon: Icon(Iconz().podcast),
          selectedIcon: Icon(Iconz().podcastFilled),
          label: context.l10n.podcasts,
        ),
      ]
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 23),
              child: e,
            ),
          )
          .toList(),
    );
  }
}
