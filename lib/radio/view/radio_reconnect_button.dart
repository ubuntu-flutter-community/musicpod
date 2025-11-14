import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/connectivity_model.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';
import 'disconnected_server_icon.dart';

class RadioReconnectButton extends StatelessWidget with WatchItMixin {
  const RadioReconnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);

    return TextButton.icon(
      label: Text(
        '${context.l10n.noRadioServerFound}: ${context.l10n.tryReconnect}',
      ),
      onPressed: isOnline
          ? () async {
              final radioModel = di<RadioModel>();
              await radioModel.reconnect();
              final connectedHost = radioModel.connectedHost;
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    connectedHost != null
                        ? '${context.l10n.connectedTo}: $connectedHost'
                        : context.l10n.noRadioServerFound,
                  ),
                ),
              );
            }
          : null,
      icon: const DisconnectedServerIcon(),
    );
  }
}
