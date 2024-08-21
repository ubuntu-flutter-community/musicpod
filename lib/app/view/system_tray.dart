import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../l10n/l10n.dart';

const _exitAppMenuKey = 'exit_app';
const _showHideWindowMenuKey = 'show_hide_window';

Future<void> initTray() async {
  await trayManager.setIcon(
    (Platform.isWindows)
        ? 'assets/images/tray_icon.ico'
        : 'assets/images/tray_icon.png',
  );
  Menu menu = Menu(
    items: [
      MenuItem(
        key: _showHideWindowMenuKey,
        label: 'Show Window',
      ),
      MenuItem.separator(),
      MenuItem(
        key: _exitAppMenuKey,
        label: 'Exit App',
      ),
    ],
  );
  await trayManager.setContextMenu(menu);
}

Future<void> updateTrayItems(BuildContext context) async {
  bool isVisible = await windowManager.isVisible();
  if (!context.mounted) return;
  final trayMenuItems = [
    MenuItem(
      key: _showHideWindowMenuKey,
      label: isVisible ? context.l10n.hideToTray : context.l10n.closeApp,
    ),
    MenuItem.separator(),
    MenuItem(
      key: _exitAppMenuKey,
      label: context.l10n.closeApp,
    ),
  ];

  await trayManager.setContextMenu(Menu(items: trayMenuItems));
}

void reactToTray(MenuItem menuItem) {
  switch (menuItem.key) {
    case _showHideWindowMenuKey:
      windowManager.isVisible().then((value) {
        if (value) {
          windowManager.hide();
        } else {
          windowManager.show();
        }
      });
    case _exitAppMenuKey:
      windowManager.close();
  }
}
