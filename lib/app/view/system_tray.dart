import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../persistence_utils.dart';

class SystemTray with TrayListener {
  Future<void> init() async {
    trayManager.addListener(this);
    await trayManager.setIcon(trayIcon());
    await trayManager.setContextMenu(Menu(items: trayMenuItems));
  }

  // KDE@Arch Linux, this feature does not work.
  // @override
  // void onTrayIconMouseDown() {
  //   print('onTrayIconMouseDown');
  // }

  // KDE@Arch Linux, this feature does not work.
  // @override
  // void onTrayIconRightMouseDown() {
  //   print('onTrayIconRightMouseDown');
  // }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'restore_window':
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
