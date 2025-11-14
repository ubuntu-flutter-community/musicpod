import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/page_ids.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import 'routing_manager.dart';

class MobileNavigationBar extends StatelessWidget with WatchItMixin {
  const MobileNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final selectedPageId = watchPropertyValue(
      (RoutingManager m) => m.selectedPageId,
    );

    final sizedBox = SizedBox(
      height:
          navigationBarHeight -
          (context.isAndroidGestureNavigationEnabled ? 0 : 15),
      child: Padding(
        padding: context.isAndroidGestureNavigationEnabled
            ? const EdgeInsets.only(bottom: 10)
            : const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              isSelected: selectedPageId == PageIDs.homePage,
              selectedIcon: Icon(Iconz.homeFilled, semanticLabel: l10n.home),
              icon: Icon(Iconz.home, semanticLabel: l10n.home),
              tooltip: l10n.home,
              onPressed: () =>
                  di<RoutingManager>().push(pageId: PageIDs.homePage),
            ),
            IconButton(
              isSelected: selectedPageId == PageIDs.localAudio,
              selectedIcon: Icon(
                Iconz.localAudioFilled,
                semanticLabel: l10n.local,
              ),
              icon: Icon(Iconz.localAudio, semanticLabel: l10n.local),
              tooltip: l10n.local,
              onPressed: () =>
                  di<RoutingManager>().push(pageId: PageIDs.localAudio),
            ),
            IconButton(
              isSelected: selectedPageId == PageIDs.radio,
              selectedIcon: Icon(Iconz.radioFilled, semanticLabel: l10n.radio),
              icon: Icon(Iconz.radio, semanticLabel: l10n.radio),
              tooltip: l10n.radio,
              onPressed: () => di<RoutingManager>().push(pageId: PageIDs.radio),
            ),
            IconButton(
              isSelected: selectedPageId == PageIDs.podcasts,
              selectedIcon: Icon(
                Iconz.podcastFilled,
                semanticLabel: l10n.podcasts,
              ),
              icon: Icon(Iconz.podcast, semanticLabel: l10n.podcasts),
              tooltip: l10n.podcasts,
              onPressed: () =>
                  di<RoutingManager>().push(pageId: PageIDs.podcasts),
            ),
            IconButton(
              isSelected: selectedPageId == PageIDs.settings,
              selectedIcon: Icon(
                Iconz.settingsFilled,
                semanticLabel: l10n.settings,
              ),
              icon: Icon(Iconz.settings, semanticLabel: l10n.settings),
              tooltip: l10n.settings,
              onPressed: () =>
                  di<RoutingManager>().push(pageId: PageIDs.settings),
            ),
          ],
        ),
      ),
    );

    if (context.isAndroidGestureNavigationEnabled) {
      return sizedBox;
    }

    return SafeArea(child: sizedBox);
  }
}
