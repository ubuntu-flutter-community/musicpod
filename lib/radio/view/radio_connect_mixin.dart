import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/progress.dart';
import '../../common/view/snackbars.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';

mixin RadioConnectMixin {
  void registerRadioConnectHandler(BuildContext context) {
    registerHandler(
      select: (RadioManager m) => m.connectCommand.results,
      handler: (context, results, cancel) {
        final connectedHost = results.data;
        final isRunning = results.isRunning;
        showSnackBar(
          context: context,
          duration: const Duration(seconds: 3),
          content: isRunning
              ? const Progress()
              : Text(
                  connectedHost != null
                      ? '${context.l10n.connectedTo}: $connectedHost'
                      : context.l10n.noRadioServerFound,
                ),
          action: connectedHost == null && !isRunning
              ? SnackBarAction(
                  label: context.l10n.tryReconnect,
                  onPressed: di<RadioManager>().connectCommand,
                )
              : null,
        );
      },
    );
  }
}
