import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../player/view/player_view.dart';
import '../full_window_mode_manager.dart';
import 'common_handlers_and_commands.dart';
import 'master_panel.dart';
import 'mobile_bottom_bar.dart';
import 'mobile_page.dart';

class MasterDetailShell extends ConsumerWidget {
  const MasterDetailShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInFullWindowMode = ref.watch(fullWindowModeManagerProvider);

    return _MasterDetailShellContent(
      isInFullWindowMode: isInFullWindowMode,
      onDismissFullWindowMode: () => ref
          .read(fullWindowModeManagerProvider.notifier)
          .setFullWindowMode(false),
      child: child,
    );
  }
}

class _MasterDetailShellContent extends ConsumerStatefulWidget {
  const _MasterDetailShellContent({
    required this.isInFullWindowMode,
    required this.onDismissFullWindowMode,
    required this.child,
  });

  final bool isInFullWindowMode;
  final VoidCallback onDismissFullWindowMode;
  final Widget child;

  @override
  ConsumerState<_MasterDetailShellContent> createState() =>
      _MasterDetailShellContentState();
}

class _MasterDetailShellContentState
    extends ConsumerState<_MasterDetailShellContent>
    with CommonHandlersAndCommandsMixin {
  @override
  void initState() {
    super.initState();
    callCommonCommands(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    registerCommonHandlers(context, ref);

    return PopScope(
      canPop: !widget.isInFullWindowMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.isInFullWindowMode) {
          widget.onDismissFullWindowMode();
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
                Expanded(child: widget.child),
              ],
            ),
            if (widget.isInFullWindowMode) const PlayerView.fullWindow(),
          ],
        ),
        bottomNavigationBar: isMobile
            ? ((!context.showMasterPanel && !widget.isInFullWindowMode)
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
