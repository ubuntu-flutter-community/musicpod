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

class MasterDetailPage extends StatelessWidget with WatchItMixin {
  const MasterDetailPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: isMobile ? false : null,
    key: masterScaffoldKey,
    endDrawer: isMacOS ? const _Drawer() : null,
    drawer: isMacOS ? null : const _Drawer(),
    body: Row(
      children: [
        if (context.showMasterPanel) ...[
          const MasterPanel(),
          const VerticalDivider(width: 1),
        ],
        Expanded(
          child: Navigator(
            initialRoute: watchValue(
              (RoutingManager m) => m.selectedPageIdCommand,
            ),
            key: di<RoutingManager>().masterNavigatorKey,
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

class _Drawer extends StatelessWidget {
  const _Drawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
  }
}
