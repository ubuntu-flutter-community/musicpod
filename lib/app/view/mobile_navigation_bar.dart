import '../../common/data/audio_type.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import 'main_page_icon.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class MobileNavigationBar extends StatelessWidget with WatchItMixin {
  const MobileNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final selectedPageId =
        watchPropertyValue((LibraryModel m) => m.selectedPageId);

    return SizedBox(
      height: navigationBarHeight,
      child: Padding(
        padding: const EdgeInsets.only(top: kMediumSpace),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              isSelected: selectedPageId == kHomePageId,
              selectedIcon: Icon(Iconz.homeFilled),
              icon: Icon(Iconz.home),
              tooltip: l10n.home,
              onPressed: () => di<LibraryModel>().push(pageId: kHomePageId),
            ),
            IconButton(
              isSelected: selectedPageId == kLocalAudioPageId,
              selectedIcon: const MainPageIcon(
                selected: true,
                audioType: AudioType.local,
              ),
              icon: const MainPageIcon(
                selected: false,
                audioType: AudioType.local,
              ),
              tooltip: l10n.local,
              onPressed: () =>
                  di<LibraryModel>().push(pageId: kLocalAudioPageId),
            ),
            IconButton(
              isSelected: selectedPageId == kRadioPageId,
              selectedIcon: const MainPageIcon(
                selected: true,
                audioType: AudioType.radio,
              ),
              icon: const MainPageIcon(
                selected: false,
                audioType: AudioType.radio,
              ),
              tooltip: l10n.radio,
              onPressed: () => di<LibraryModel>().push(pageId: kRadioPageId),
            ),
            IconButton(
              isSelected: selectedPageId == kPodcastsPageId,
              selectedIcon: const MainPageIcon(
                selected: true,
                audioType: AudioType.podcast,
              ),
              icon: const MainPageIcon(
                selected: false,
                audioType: AudioType.podcast,
              ),
              tooltip: l10n.podcasts,
              onPressed: () => di<LibraryModel>().push(pageId: kPodcastsPageId),
            ),
          ],
        ),
      ),
    );
  }
}
