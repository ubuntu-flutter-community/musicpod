import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/view/bottom_player.dart';
import '../../player/view/full_height_player.dart';
import '../../player/view/player_view.dart';
import '../app_model.dart';
import 'main_page_icon.dart';

class MobilePlayerAndNavigationBar extends StatelessWidget with WatchItMixin {
  const MobilePlayerAndNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fullWindowMode =
        watchPropertyValue((AppModel m) => m.fullWindowMode) ?? false;

    return RepaintBoundary(
      child: Material(
        color: context.theme.cardColor,
        child: fullWindowMode
            ? const FullHeightPlayer(
                playerPosition: PlayerPosition.fullWindow,
              )
            : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BottomPlayer(),
                  SizedBox(height: kMediumSpace),
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
      kSettingsPageId: NavigationDestination(
        selectedIcon: Icon(Iconz.settingsFilled),
        icon: Icon(Iconz.settings),
        label: l10n.settings,
      ),
    };

    return NavigationBar(
      height: bottomPlayerHeight - 25,
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
