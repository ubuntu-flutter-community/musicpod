import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/snackbars.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';

class RadioConnectSnackbar extends StatelessWidget {
  const RadioConnectSnackbar({super.key, this.connectedHost});

  final String? connectedHost;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SnackBar(
      duration: connectedHost != null
          ? const Duration(seconds: 1)
          : const Duration(seconds: 30),
      content: Text(
        connectedHost != null
            ? '${l10n.connectedTo}: $connectedHost'
            : l10n.noRadioServerFound,
      ),
      action: (connectedHost == null)
          ? SnackBarAction(
              onPressed: () async {
                final connectedHost = await di<RadioModel>().init();
                if (context.mounted) {
                  showSnackBar(
                    context: context,
                    content: RadioConnectSnackbar(connectedHost: connectedHost),
                  );
                }
              },
              label: l10n.tryReconnect,
            )
          : null,
    );
  }
}
