import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/snackbars.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';
import 'disconnected_server_icon.dart';
import 'radio_connect_snackbar.dart';

class RadioReconnectButton extends StatelessWidget {
  const RadioReconnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    final model = di<RadioModel>();

    return TextButton.icon(
      label: Text(
        '${context.l10n.noRadioServerFound}: ${context.l10n.tryReconnect}',
      ),
      onPressed: () => model.init().then(
        (host) {
          if (context.mounted) {
            showSnackBar(
              context: context,
              content: buildConnectSnackBar(
                connectedHost: host,
                context: context,
              ),
              duration: Duration(
                seconds: host == null ? 10 : 3,
              ),
            );
          }
        },
      ),
      icon: const DisconnectedServerIcon(),
    );
  }
}
