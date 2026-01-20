import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../app/view/routing_manager.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import 'global_keys.dart';
import 'icons.dart';
import 'nav_back_button.dart';

class HeaderBar extends StatelessWidget
    with WatchItMixin
    implements PreferredSizeWidget {
  const HeaderBar({
    super.key,
    this.title,
    this.actions,
    this.style = YaruTitleBarStyle.normal,
    this.titleSpacing = 0,
    this.backgroundColor,
    this.foregroundColor,
    required this.adaptive,
    this.includeBackButton = true,
    this.includeSidebarButton = true,
  });

  final Widget? title;
  final List<Widget>? actions;
  final YaruTitleBarStyle style;
  final double? titleSpacing;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final bool adaptive;
  final bool includeBackButton;
  final bool includeSidebarButton;

  @override
  Widget build(BuildContext context) {
    final useSidebarButton = isMobile ? false : includeSidebarButton;
    final useBackButton = isMobile ? true : includeBackButton;

    Widget? leading;

    final canPop = watchPropertyValue((RoutingManager m) => m.canPop);

    if (useSidebarButton &&
        !context.showMasterPanel &&
        masterScaffoldKey.currentState?.isDrawerOpen == false) {
      leading = const SidebarButton();
    } else {
      if (useBackButton && canPop) {
        leading = const NavBackButton();
      } else {
        leading = isMobile ? const SizedBox(width: 60) : null;
      }
    }

    if (isMobile) {
      return AppBar(
        backgroundColor: backgroundColor,
        titleSpacing: titleSpacing,
        centerTitle: true,
        title: title ?? const Text(''),
        actions: actions,
        foregroundColor: foregroundColor,
        automaticallyImplyLeading: includeBackButton,
      );
    }

    var theStyle = style;
    if (adaptive) {
      theStyle = watchPropertyValue((AppModel m) => m.showWindowControls)
          ? YaruTitleBarStyle.normal
          : YaruTitleBarStyle.undecorated;
    }

    return Theme(
      data: context.theme.copyWith(
        appBarTheme: AppBarTheme.of(
          context,
        ).copyWith(scrolledUnderElevation: 0),
      ),
      child: YaruWindowTitleBar(
        titleSpacing: titleSpacing,
        actions: [
          if ((!context.showMasterPanel && isMacOS) && leading != null)
            Padding(padding: const EdgeInsets.only(left: 10), child: leading),
          ...?actions,
        ],
        leading: !context.showMasterPanel && isMacOS ? null : leading,
        title: title ?? const Text(''),
        border: BorderSide.none,
        backgroundColor:
            backgroundColor ?? context.theme.scaffoldBackgroundColor,
        style: theStyle,
        foregroundColor: foregroundColor,
      ),
    );
  }

  @override
  Size get preferredSize => Size(
    0,
    isMobile
        ? (style == YaruTitleBarStyle.hidden ? 0 : kYaruTitleBarHeight)
        : kToolbarHeight,
  );
}

class SidebarButton extends StatelessWidget {
  const SidebarButton({super.key});

  @override
  Widget build(BuildContext context) {
    final iconSize = context.theme.iconTheme.size ?? 24.0;
    return Center(
      child: IconButton(
        onPressed: () {
          if (isMacOS) {
            masterScaffoldKey.currentState?.openEndDrawer();
          } else {
            masterScaffoldKey.currentState?.openDrawer();
          }
        },
        icon: Iconz.sidebar == Iconz.materialSidebar
            ? Transform.flip(flipX: true, child: Icon(Iconz.materialSidebar))
            : Icon(Iconz.sidebar, size: iconSize),
      ),
    );
  }
}
