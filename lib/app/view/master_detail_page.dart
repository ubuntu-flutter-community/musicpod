import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
import '../../common/page_ids.dart';
import '../../common/view/back_gesture.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../library/library_model.dart';
import 'create_master_items.dart';
import 'master_panel.dart';
import 'routing_manager.dart';

class MasterDetailPage extends StatelessWidget {
  const MasterDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final routingManager = di<RoutingManager>();

    final drawer = Drawer(
      width: kMasterDetailSideBarWidth,
      child: Stack(
        children: [
          const MasterPanel(),
          Positioned(
            left: Platform.isMacOS ? 5 : null,
            top: 5,
            right: Platform.isMacOS ? null : 5,
            child: IconButton(
              onPressed: Platform.isMacOS
                  ? masterScaffoldKey.currentState?.closeEndDrawer
                  : masterScaffoldKey.currentState?.closeDrawer,
              icon: Icon(
                Iconz.close,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: AppConfig.isMobilePlatform ? false : null,
      key: masterScaffoldKey,
      endDrawer: Platform.isMacOS ? drawer : null,
      drawer: Platform.isMacOS ? null : drawer,
      body: Row(
        children: [
          if (context.showMasterPanel) const MasterPanel(),
          if (context.showMasterPanel) const VerticalDivider(),
          Expanded(
            child: Navigator(
              initialRoute: routingManager.selectedPageId ?? PageIDs.searchPage,
              onDidRemovePage: (page) {},
              key: routingManager.masterNavigatorKey,
              observers: [routingManager],
              onGenerateRoute: (settings) {
                final masterItems = getAllMasterItems(di<LibraryModel>());
                final page = (masterItems.firstWhereOrNull(
                          (e) => e.pageId == settings.name,
                        ) ??
                        masterItems.elementAt(0))
                    .pageBuilder(context);

                return PageRouteBuilder(
                  settings: settings,
                  maintainState: PageIDs.permanent.contains(settings.name),
                  pageBuilder: (_, __, ___) => BackGesture(child: page),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
