import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/icons.dart';
import '../../common/view/snackbars.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';

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
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            buildConnectSnackBar(
              connectedHost: host,
              context: context,
            ),
          );
        },
      ),
      icon: const DisconnectedServerIcon(),
    );
  }
}
