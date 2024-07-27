import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../l10n/l10n.dart';
import '../../radio/radio_model.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
  required BuildContext context,
  required Widget content,
  Duration? duration,
  clear = true,
}) {
  if (clear) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: content,
      duration: duration ?? const Duration(seconds: 10),
    ),
  );
}

SnackBar buildConnectSnackBar({
  required String? connectedHost,
  required BuildContext context,
}) {
  return SnackBar(
    duration: connectedHost != null
        ? const Duration(seconds: 1)
        : const Duration(seconds: 30),
    content: Text(
      connectedHost != null
          ? '${context.l10n.connectedTo}: $connectedHost'
          : context.l10n.noRadioServerFound,
    ),
    action: (connectedHost == null)
        ? SnackBarAction(
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              di<RadioModel>().init().then(
                    (value) => ScaffoldMessenger.of(context).showSnackBar(
                      buildConnectSnackBar(
                        connectedHost: value,
                        context: context,
                      ),
                    ),
                  );
            },
            label: context.l10n.tryReconnect,
          )
        : null,
  );
}
