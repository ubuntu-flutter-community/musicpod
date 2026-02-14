import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/app_model.dart';
import '../../app/view/routing_manager.dart';
import '../../common/page_ids.dart';
import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../settings_model.dart';
import 'settings_tile.dart';

enum _SettingsButtonMode { icon, important, tile }

class SettingsButton extends StatelessWidget {
  const SettingsButton.icon({super.key, this.scrollIndex = 0})
    : _mode = _SettingsButtonMode.icon;

  const SettingsButton.important({super.key, this.scrollIndex = 0})
    : _mode = _SettingsButtonMode.important;

  const SettingsButton.tile({super.key, this.scrollIndex = 0})
    : _mode = _SettingsButtonMode.tile;

  final _SettingsButtonMode _mode;
  final int scrollIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Future<void> onPressed() async {
      await di<AppModel>().setFullWindowMode(false);
      await Future.delayed(const Duration(milliseconds: 300));
      di<SettingsModel>().scrollIndex = scrollIndex;
      await di<RoutingManager>().push(pageId: PageIDs.settings);
    }

    return switch (_mode) {
      _SettingsButtonMode.icon => IconButton(
        tooltip: l10n.settings,
        onPressed: onPressed,
        icon: Icon(Iconz.settings, semanticLabel: l10n.settings),
      ),
      _SettingsButtonMode.important => ElevatedButton(
        onPressed: onPressed,
        child: Text(context.l10n.settings),
      ),
      _SettingsButtonMode.tile => const SettingsTile(),
    };
  }
}
