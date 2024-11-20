import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/view/bottom_player.dart';
import '../../player/view/full_height_player.dart';
import '../../player/view/player_view.dart';
import '../app_model.dart';
import 'main_page_icon.dart';

class MobilePlayerAndNavigationBar extends StatelessWidget {
  const MobilePlayerAndNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: context.theme.cardColor,
        child: watchPropertyValue((AppModel m) => m.fullWindowMode) ?? false
            ? const FullHeightPlayer(
                playerPosition: PlayerPosition.fullWindow,
              )
            : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BottomPlayer(),
                  MobileNavigationBar(),
                ],
              ),
      ),
    );
  }
}

class MobileNavigationBar extends StatelessWidget with WatchItMixin {
  const MobileNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final selectedPageId =
        watchPropertyValue((LibraryModel m) => m.selectedPageId);

    final destinations = <String, NavigationDestination>{
      kSearchPageId: NavigationDestination(
        selectedIcon: Icon(Iconz.search),
        icon: Icon(Iconz.search),
        label: l10n.search,
      ),
      kLocalAudioPageId: NavigationDestination(
        selectedIcon:
            const MainPageIcon(selected: true, audioType: AudioType.local),
        icon: const MainPageIcon(selected: false, audioType: AudioType.local),
        label: l10n.local,
      ),
      kRadioPageId: NavigationDestination(
        selectedIcon:
            const MainPageIcon(selected: true, audioType: AudioType.radio),
        icon: const MainPageIcon(selected: false, audioType: AudioType.radio),
        label: l10n.radio,
      ),
      kPodcastsPageId: NavigationDestination(
        selectedIcon:
            const MainPageIcon(selected: true, audioType: AudioType.podcast),
        icon: const MainPageIcon(selected: false, audioType: AudioType.podcast),
        label: l10n.podcasts,
      ),
    };

    return NavigationBar(
      backgroundColor: context.theme.cardColor,
      selectedIndex: selectedPageId == null
          ? 0
          : destinations.keys.toList().indexOf(selectedPageId),
      onDestinationSelected: (index) =>
          di<LibraryModel>().push(pageId: destinations.keys.elementAt(index)),
      destinations: destinations.values.toList(),
    );
  }
}
