import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../settings/settings_model.dart';
import 'confirm.dart';

class BandwidthDialog extends StatelessWidget {
  const BandwidthDialog({
    super.key,
    this.backOnBetterConnection = false,
  });

  final bool backOnBetterConnection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ConfirmationDialog(
      title: Text(
        backOnBetterConnection
            ? l10n.isBackInWifiDialogTitle
            : l10n.isMaybeLowBandwidthDialogTitle,
      ),
      content: Text(
        backOnBetterConnection
            ? l10n.isBackInWifiDialogBody
            : l10n.isMaybeLowBandwidthDialogBody,
      ),
      onConfirm: () =>
          di<PlayerModel>().setDataSafeMode(!backOnBetterConnection),
      cancelLabel: l10n.stopToNotifyAboutDataSafeMode,
      onCancel: () => di<SettingsModel>().setNotifyDataSafeMode(false),
    );
  }
}
