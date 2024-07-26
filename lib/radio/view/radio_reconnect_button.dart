import '../../app/app_model.dart';
import '../../common/view/icons.dart';
import '../../common/view/snackbars.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class RadioReconnectButton extends StatelessWidget {
  const RadioReconnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    final model = di<RadioModel>();
    final appModel = di<AppModel>();

    return IconButton(
      tooltip:
          '${context.l10n.noRadioServerFound}: ${context.l10n.tryReconnect}',
      onPressed: () => model
          .init(
        countryCode: appModel.countryCode,
        index: appModel.radioindex,
      )
          .then(
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
