import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/connectivity_manager.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';
import 'disconnected_server_icon.dart';

class RadioReconnectButton extends StatelessWidget with WatchItMixin {
  const RadioReconnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = watchValue(
      (ConnectivityManager m) =>
          m.connectivityCommand.select((p) => p.isOnline),
    );

    return TextButton.icon(
      label: Text(
        '${context.l10n.noRadioServerFound}: ${context.l10n.tryReconnect}',
      ),
      onPressed: isOnline ? di<RadioManager>().connectCommand.run : null,
      icon: const DisconnectedServerIcon(),
    );
  }
}
