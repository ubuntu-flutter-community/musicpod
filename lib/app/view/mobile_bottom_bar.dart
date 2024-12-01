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
import '../app_model.dart';
import 'main_page_icon.dart';

class MobileBottomBar extends StatelessWidget with WatchItMixin {
  const MobileBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fullWindowMode =
        watchPropertyValue((AppModel m) => m.fullWindowMode) ?? false;
    return SizedBox(
      width: context.mediaQuerySize.width,
      child: RepaintBoundary(
        child: Material(
          color: context.theme.cardColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: bottomPlayerHeight, child: const BottomPlayer()),
              const SizedBox(height: kMediumSpace),
              if (!fullWindowMode) const MobileNavigationBar(),
            ],
          ),
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

    final destinations = <String, IconButton>{
      kLocalAudioPageId: IconButton(
        isSelected: selectedPageId == kLocalAudioPageId,
        selectedIcon:
            const MainPageIcon(selected: true, audioType: AudioType.local),
        icon: const MainPageIcon(selected: false, audioType: AudioType.local),
        tooltip: l10n.local,
        onPressed: () => di<LibraryModel>().push(pageId: kLocalAudioPageId),
      ),
      kRadioPageId: IconButton(
        isSelected: selectedPageId == kRadioPageId,
        selectedIcon:
            const MainPageIcon(selected: true, audioType: AudioType.radio),
        icon: const MainPageIcon(selected: false, audioType: AudioType.radio),
        tooltip: l10n.radio,
        onPressed: () => di<LibraryModel>().push(pageId: kRadioPageId),
      ),
      kPodcastsPageId: IconButton(
        isSelected: selectedPageId == kPodcastsPageId,
        selectedIcon:
            const MainPageIcon(selected: true, audioType: AudioType.podcast),
        icon: const MainPageIcon(selected: false, audioType: AudioType.podcast),
        tooltip: l10n.podcasts,
        onPressed: () => di<LibraryModel>().push(pageId: kPodcastsPageId),
      ),
      kSettingsPageId: IconButton(
        isSelected: selectedPageId == kSettingsPageId,
        selectedIcon: Icon(Iconz.settingsFilled),
        icon: Icon(Iconz.settings),
        tooltip: l10n.settings,
        onPressed: () => di<LibraryModel>().push(pageId: kSettingsPageId),
      ),
    };

    return SizedBox(
      height: navigationBarHeight,
      width: context.mediaQuerySize.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: destinations.values.toList(),
      ),
    );
  }
}
