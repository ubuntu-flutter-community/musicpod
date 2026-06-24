import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../page_ids.dart';
import '../routing_manager.dart';
import 'master_item_page.dart';
import 'master_panel.dart';

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
            left: isMacOS ? 5 : null,
            top: 5,
            right: isMacOS ? null : 5,
            child: IconButton(
              onPressed: isMacOS
                  ? masterScaffoldKey.currentState?.closeEndDrawer
                  : masterScaffoldKey.currentState?.closeDrawer,
              icon: Icon(Iconz.close),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      key: masterScaffoldKey,
      endDrawer: isMacOS ? drawer : null,
      drawer: isMacOS ? null : drawer,
      body: Row(
        children: [
          if (context.showMasterPanel) ...[
            const MasterPanel(),
            const VerticalDivider(),
          ],
          Expanded(
            child: Navigator(
              initialRoute: routingManager.selectedPageId ?? PageIDs.searchPage,
              onDidRemovePage: (page) {},
              key: routingManager.masterNavigatorKey,
              observers: [routingManager],
              onGenerateRoute: (settings) => PageRouteBuilder(
                settings: settings,
                maintainState: false,
                pageBuilder: (context, _, __) =>
                    MasterItemPage(pageId: settings.name ?? PageIDs.searchPage),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
