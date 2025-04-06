import 'dart:io';

import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../app_config.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../settings/settings_model.dart';
import '../data/close_btn_action.dart';
import 'global_keys.dart';
import 'icons.dart';
import 'nav_back_button.dart';
import 'theme.dart';

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
    final useSidebarButton =
        AppConfig.isMobilePlatform ? false : includeSidebarButton;
    final useBackButton = AppConfig.isMobilePlatform ? true : includeBackButton;
    final canPop = watchPropertyValue((LibraryModel m) => m.canPop);

    Widget? leading;

    if (useSidebarButton &&
        !context.showMasterPanel &&
        masterScaffoldKey.currentState?.isDrawerOpen == false) {
      leading = const SidebarButton();
    } else {
      if (useBackButton && canPop) {
        leading = const NavBackButton();
      } else {
        leading = AppConfig.isMobilePlatform
            ? const SizedBox(
                width: 60,
              )
            : null;
      }
    }

    if (AppConfig.isMobilePlatform) {
      return AppBar(
        backgroundColor: backgroundColor,
        titleSpacing: titleSpacing,
        centerTitle: true,
        leading: leading,
        title: title ?? const Text(''),
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

    return Theme(
      data: context.theme.copyWith(
        appBarTheme: AppBarTheme.of(context).copyWith(
          scrolledUnderElevation: 0,
        ),
      ),
      child: YaruWindowTitleBar(
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
        AppConfig.isMobilePlatform
            ? (style == YaruTitleBarStyle.hidden ? 0 : kYaruTitleBarHeight)
            : kToolbarHeight,
      );
}

class CloseWindowActionConfirmDialog extends StatefulWidget {
  const CloseWindowActionConfirmDialog({super.key});

  @override
  State<CloseWindowActionConfirmDialog> createState() =>
      _CloseWindowActionConfirmDialogState();
}

class _CloseWindowActionConfirmDialogState
    extends State<CloseWindowActionConfirmDialog> {
  bool rememberChoice = false;
  @override
  Widget build(BuildContext context) {
    final model = di<SettingsModel>();
    return AlertDialog(
      title: AppConfig.yaruStyled
          ? YaruDialogTitleBar(
              backgroundColor: Colors.transparent,
              title: Text(context.l10n.closeMusicPod),
            )
          : null,
      titlePadding: AppConfig.yaruStyled ? EdgeInsets.zero : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error,
            color: Colors.red,
            size: 50,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.confirmCloseOrHideTip,
          ),
          CheckboxListTile(
            title: Text(context.l10n.doNotAskAgain),
            value: rememberChoice,
            onChanged: (value) {
              setState(() {
                rememberChoice = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (rememberChoice) {
              model.setCloseBtnActionIndex(CloseBtnAction.hideToTray);
            }
            Navigator.of(context).pop();
            YaruWindow.hide(context);
          },
          child: Text(context.l10n.hideToTray),
        ),
        TextButton(
          onPressed: () {
            if (rememberChoice) {
              model.setCloseBtnActionIndex(CloseBtnAction.close);
            }
            Navigator.of(context).pop();
            YaruWindow.close(context);
          },
          child: Text(context.l10n.closeApp),
        ),
      ],
    );
  }
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
        icon: Iconz.sidebar == Iconz.materialSidebar
            ? Transform.flip(flipX: true, child: Icon(Iconz.materialSidebar))
            : Icon(
                Iconz.sidebar,
                size: iconSize,
              ),
      ),
    );
  }
}
