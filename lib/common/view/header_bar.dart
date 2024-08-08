import 'dart:io';

import '../../app/app_model.dart';
import '../../extensions/build_context_x.dart';
import '../../library/library_model.dart';
import 'global_keys.dart';
import 'icons.dart';
import 'nav_back_button.dart';
import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart' hide isMobile;
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

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
    final canPop = watchPropertyValue((LibraryModel m) => m.canPop);

    Widget? leading;

    if (includeSidebarButton &&
        !context.showMasterPanel &&
        masterScaffoldKey.currentState?.isDrawerOpen == false) {
      leading = const SidebarButton();
    } else {
      if (includeBackButton && canPop) {
        leading = const NavBackButton();
      } else {
        leading = null;
      }
    }

    if (isMobile) {
      return AppBar(
        titleSpacing: titleSpacing,
        centerTitle: true,
        leading: leading,
        title: title,
        actions: actions,
        foregroundColor: foregroundColor,
      );
    }

    var theStyle = style;
    if (adaptive) {
      theStyle = watchPropertyValue((AppModel m) => m.showWindowControls)
          ? YaruTitleBarStyle.normal
          : YaruTitleBarStyle.undecorated;
    }

    return YaruWindowTitleBar(
      titleSpacing: titleSpacing,
      actions: [
        if ((!context.showMasterPanel && Platform.isMacOS) && leading != null)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: leading,
          ),
        ...?actions,
      ],
      leading: !context.showMasterPanel && Platform.isMacOS ? null : leading,
      title: title,
      border: BorderSide.none,
      backgroundColor: backgroundColor ?? context.theme.scaffoldBackgroundColor,
      style: theStyle,
      foregroundColor: foregroundColor,
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
    return Center(
      child: IconButton(
        onPressed: () {
          if (Platform.isMacOS) {
            masterScaffoldKey.currentState?.openEndDrawer();
          } else {
            masterScaffoldKey.currentState?.openDrawer();
          }
        },
        icon: Icon(
          Iconz().sidebar,
        ),
      ),
    );
  }
}
