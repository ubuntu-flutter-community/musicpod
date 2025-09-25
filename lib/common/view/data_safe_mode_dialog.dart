import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/connectivity_model.dart';
import '../../extensions/connectivity_x.dart';
import '../../l10n/l10n.dart';
import '../../radio/radio_model.dart';
import '../../settings/settings_model.dart';
import 'confirm.dart';

class DataSafeModeDialog extends StatelessWidget with WatchItMixin {
  const DataSafeModeDialog({super.key, required this.cancel});

  final void Function() cancel;

  @override
  Widget build(BuildContext context) {
    final isEthernetOrWifi = watchPropertyValue(
      (ConnectivityModel m) =>
          !di<Connectivity>().isNotWifiNorEthernet(m.result),
    );

    final l10n = context.l10n;
    return ConfirmationDialog(
      title: Text(
        isEthernetOrWifi
            ? l10n.isBackInWifiDialogTitle
            : l10n.isMaybeLowBandwidthDialogTitle,
      ),
      content: Text(
        isEthernetOrWifi
            ? l10n.isBackInWifiDialogBody
            : l10n.isMaybeLowBandwidthDialogBody,
      ),
      onConfirm: () async =>
          di<RadioModel>().setDataSafeMode(!isEthernetOrWifi),
      cancelLabel: l10n.stopToNotifyAboutDataSafeMode,
      onCancel: () async {
        di<SettingsModel>().setNotifyDataSafeMode(false);
        cancel();
      },
    );
  }
}
