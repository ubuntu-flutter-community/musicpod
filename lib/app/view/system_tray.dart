import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

String trayIcon() {
  if (Platform.isWindows) {
    return 'assets/images/tray_icon.ico';
  } else {
    return 'assets/images/tray_icon.png';
  }
}

class SystemTray with TrayListener {
  late List<MenuItem> trayMenuItems;

  Future<void> init() async {
    trayManager.addListener(this);
    await trayManager.setIcon(trayIcon());
  }

  Future<void> dispose() async {
    trayManager.removeListener(this);
  }

  Future<void> updateTrayMenuItems(
    BuildContext context,
  ) async {
    bool isVisible = await windowManager.isVisible();

    trayMenuItems = [
      MenuItem(
        key: 'show_hide_window',
        label: isVisible ? 'Hide Window' : 'Show Window',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'close_application',
        label: 'Close Application',
      ),
    ];

    await trayManager.setContextMenu(Menu(items: trayMenuItems));
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_hide_window':
        windowManager.isVisible().then((value) {
          if (value) {
            windowManager.hide();
          } else {
            windowManager.show();
          }
        });
      case 'close_application':
        windowManager.close();
    }
  }
}
