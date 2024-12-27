import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
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
        padding:
            const EdgeInsets.only(bottom: kLargestSpace, top: kSmallestSpace),
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
              selectedIcon: Icon(Iconz.localAudioFilled),
              icon: Icon(Iconz.localAudio),
              tooltip: l10n.local,
              onPressed: () =>
                  di<LibraryModel>().push(pageId: kLocalAudioPageId),
            ),
            IconButton(
              isSelected: selectedPageId == kRadioPageId,
              selectedIcon: Icon(Iconz.radioFilled),
              icon: Icon(Iconz.radio),
              tooltip: l10n.radio,
              onPressed: () => di<LibraryModel>().push(pageId: kRadioPageId),
            ),
            IconButton(
              isSelected: selectedPageId == kPodcastsPageId,
              selectedIcon: Icon(Iconz.podcastFilled),
              icon: Icon(Iconz.podcast),
              tooltip: l10n.podcasts,
              onPressed: () => di<LibraryModel>().push(pageId: kPodcastsPageId),
            ),
          ],
        ),
      ),
    );
  }
}
