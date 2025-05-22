import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/page_ids.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';
import '../../player/view/full_height_player.dart';
import '../../player/view/player_main_controls.dart';
import '../../player/view/player_view.dart';
import '../../podcasts/download_model.dart';
import '../app_model.dart';
import '../connectivity_model.dart';
import 'create_master_items.dart';
import 'mobile_bottom_bar.dart';
import 'routing_manager.dart';

class MobilePage extends StatelessWidget with WatchItMixin {
  const MobilePage({super.key, required this.page});

  final Widget page;

  @override
  Widget build(BuildContext context) {
    final fullWindowMode =
        watchPropertyValue((AppModel m) => m.fullWindowMode) ?? false;

    registerStreamHandler(
      select: (DownloadModel m) => m.messageStream,
      handler: downloadMessageStreamHandler,
    );

    registerStreamHandler(
      select: (ConnectivityModel m) => m.onConnectivityChanged,
      handler: onConnectivityChangedHandler,
    );

    return PopScope(
      canPop: !fullWindowMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (fullWindowMode) {
          di<AppModel>().setFullWindowMode(false);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        extendBodyBehindAppBar: true,
        bottomNavigationBar: (!context.showMasterPanel && !fullWindowMode)
            ? const Hero(tag: 'bottomPlayer', child: MobileBottomBar())
            : null,
        body: Row(
          children: [
            if (context.showMasterPanel && !fullWindowMode) ...[
              const Hero(tag: 'masterPanel', child: MasterRail()),
              const Hero(
                tag: 'masterPanelDivider',
                child: Material(child: VerticalDivider()),
              ),
            ],
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  page,
                  if (fullWindowMode)
                    Material(
                      color: context.theme.scaffoldBackgroundColor,
                      child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity != null) {
                            if (details.primaryVelocity! < -150) {
                              di<PlayerModel>().playNext();
                            } else if (details.primaryVelocity! > 150) {
                              di<PlayerModel>().playPrevious();
                            }
                          }
                        },
                        onVerticalDragEnd: (details) {
                          if (details.primaryVelocity != null &&
                              details.primaryVelocity! > 150) {
                            di<AppModel>().setFullWindowMode(false);
                          }
                        },
                        child: const FullHeightPlayer(
                          playerPosition: PlayerPosition.fullWindow,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MasterRail extends StatelessWidget with WatchItMixin {
  const MasterRail({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPageId = watchPropertyValue(
      (RoutingManager m) => m.selectedPageId,
    );

    final destinations = permanentMasterItems
        .map(
          (e) => NavigationRailDestination(
            icon: e.pageId == PageIDs.likedAudios
                ? Icon(Iconz.heart)
                : e.iconBuilder(false),
            label: e.titleBuilder(context),
            selectedIcon: e.pageId == PageIDs.likedAudios
                ? Icon(Iconz.heartFilled)
                : e.iconBuilder(true),
            padding: const EdgeInsets.symmetric(vertical: kSmallestSpace),
          ),
        )
        .toList();

    final selectedItem = permanentMasterItems.firstWhereOrNull(
      (e) => e.pageId == selectedPageId,
    );

    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        onDestinationSelected: (index) {
                          final item = permanentMasterItems.elementAt(index);
                          di<RoutingManager>().push(pageId: item.pageId);
                        },
                        extended: true,
                        destinations: destinations,
                        selectedIndex: selectedItem == null
                            ? 0
                            : permanentMasterItems.toList().indexOf(
                                selectedItem,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Material(
            color: Colors.transparent,
            child: PlayerCompactControls(),
          ),
        ],
      ),
    );
  }
}
