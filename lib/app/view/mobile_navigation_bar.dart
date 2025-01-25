import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/page_ids.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';

class MobileNavigationBar extends StatelessWidget with WatchItMixin {
  const MobileNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final selectedPageId =
        watchPropertyValue((LibraryModel m) => m.selectedPageId);

    return Padding(
      padding: context.isAndroidGestureNavigationEnabled
          ? EdgeInsets.zero
          : const EdgeInsets.only(bottom: 35),
      child: SizedBox(
        height: navigationBarHeight,
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: kLargestSpace, top: kSmallestSpace),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                isSelected: selectedPageId == PageIDs.homePage,
                selectedIcon: Icon(Iconz.homeFilled),
                icon: Icon(Iconz.home),
                tooltip: l10n.home,
                onPressed: () =>
                    di<LibraryModel>().push(pageId: PageIDs.homePage),
              ),
              IconButton(
                isSelected: selectedPageId == PageIDs.localAudio,
                selectedIcon: Icon(Iconz.localAudioFilled),
                icon: Icon(Iconz.localAudio),
                tooltip: l10n.local,
                onPressed: () =>
                    di<LibraryModel>().push(pageId: PageIDs.localAudio),
              ),
              IconButton(
                isSelected: selectedPageId == PageIDs.radio,
                selectedIcon: Icon(Iconz.radioFilled),
                icon: Icon(Iconz.radio),
                tooltip: l10n.radio,
                onPressed: () => di<LibraryModel>().push(pageId: PageIDs.radio),
              ),
              IconButton(
                isSelected: selectedPageId == PageIDs.podcasts,
                selectedIcon: Icon(Iconz.podcastFilled),
                icon: Icon(Iconz.podcast),
                tooltip: l10n.podcasts,
                onPressed: () =>
                    di<LibraryModel>().push(pageId: PageIDs.podcasts),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
