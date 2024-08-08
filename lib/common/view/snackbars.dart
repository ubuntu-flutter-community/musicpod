import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../l10n/l10n.dart';
import '../../radio/radio_model.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
  required BuildContext context,
  Widget? content,
  SnackBar? snackBar,
  Duration? duration,
  clear = true,
}) {
  if (clear) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
  return ScaffoldMessenger.of(context).showSnackBar(
    snackBar ??
        SnackBar(
          content: content ?? const SizedBox.shrink(),
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
            onPressed: () async {
              final connectedHost = await di<RadioModel>().init();
              if (context.mounted) {
                showSnackBar(
                  context: context,
                  content: buildConnectSnackBar(
                    connectedHost: connectedHost,
                    context: context,
                  ),
                );
              }
            },
            label: context.l10n.tryReconnect,
          )
        : null,
  );
}
