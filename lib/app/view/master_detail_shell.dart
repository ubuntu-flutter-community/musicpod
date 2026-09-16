import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../player/view/player_view.dart';
import '../app_manager.dart';
import 'common_handlers_and_commands.dart';
import 'master_panel.dart';
import 'mobile_bottom_bar.dart';
import 'mobile_page.dart';

class MasterDetailShell extends StatelessWidget
    with WatchItMixin, CommonHandlersAndCommandsMixin {
  const MasterDetailShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    callCommonCommands();
    registerCommonHandlers(context);

    final isInFullWindowMode = watchValue((AppManager m) => m.fullWindowMode);

    return PopScope(
      canPop: !isInFullWindowMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isInFullWindowMode) {
          di<AppManager>().setFullWindowMode(false);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: isMobile ? false : null,
        extendBody: isMobile,
        extendBodyBehindAppBar: isMobile,
        key: masterScaffoldKey,
        endDrawer: isMacOS ? const _Drawer() : null,
        drawer: isMacOS ? null : const _Drawer(),
        body: Stack(
          children: [
            Row(
              children: [
                if (context.showMasterPanel) ...[
                  if (isMobile) ...[
                    const Hero(tag: 'masterPanel', child: MasterRail()),
                    const Hero(
                      tag: 'masterPanelDivider',
                      child: Material(child: VerticalDivider(width: 1)),
                    ),
                  ] else ...[
                    const MasterPanel(),
                    const VerticalDivider(width: 1),
                  ],
                ],
                Expanded(child: child),
              ],
            ),
            if (isInFullWindowMode) const PlayerView.fullWindow(),
          ],
        ),
        bottomNavigationBar: isMobile
            ? ((!context.showMasterPanel && !isInFullWindowMode)
                ? const Hero(tag: 'bottomPlayer', child: MobileBottomBar())
                : null)
            : const PlayerView.bottom(),
      ),
    );
  }
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
