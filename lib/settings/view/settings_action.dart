import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
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
    void onPressed() => isMobilePlatform
        ? di<LibraryModel>().push(pageId: kSettingsPageId)
        : showDialog(
            context: context,
            builder: (context) => const SettingsDialog(),
          );

    return switch (_mode) {
      _SettingsButtonMode.icon => IconButton(
          onPressed: onPressed,
          icon: Icon(Iconz.settings),
        ),
      _SettingsButtonMode.important => ImportantButton(
          onPressed: onPressed,
          child: Text(context.l10n.settings),
        ),
      _SettingsButtonMode.tile => const SettingsTile(),
    };
  }
}
