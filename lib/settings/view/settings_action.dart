import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/page_ids.dart';
import '../../common/view/icons.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import 'settings_dialog.dart';
import 'settings_tile.dart';

enum _SettingsButtonMode {
  icon,
  important,
  tile;
}

class SettingsButton extends StatelessWidget {
  const SettingsButton.icon({
    super.key,
  }) : _mode = _SettingsButtonMode.icon;

  const SettingsButton.important({
    super.key,
  }) : _mode = _SettingsButtonMode.important;

  const SettingsButton.tile({
    super.key,
  }) : _mode = _SettingsButtonMode.tile;

  final _SettingsButtonMode _mode;

  @override
  Widget build(BuildContext context) {
    void onPressed() => isMobile
        ? di<RoutingManager>().push(pageId: PageIDs.settings)
        : showDialog(
            context: context,
            builder: (context) => const SettingsDialog(),
          );

    return switch (_mode) {
      _SettingsButtonMode.icon => IconButton(
          onPressed: onPressed,
          icon: Icon(Iconz.settings),
        ),
      _SettingsButtonMode.important => ElevatedButton(
          onPressed: onPressed,
          child: Text(context.l10n.settings),
        ),
      _SettingsButtonMode.tile => const SettingsTile(),
    };
  }
}
