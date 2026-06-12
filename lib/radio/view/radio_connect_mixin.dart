import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/retry_manager.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/command_x.dart';
import '../../extensions/object_x.dart';
import '../radio_manager.dart';

mixin RadioConnectMixin {
  void registerRadioConnectHandler(BuildContext context) {
    registerHandler(
      select: (RadioManager m) => m.connectCommand.results,
      handler: (context, results, cancel) {
        if (results.hasError) {
          context.toast(
            Text(results.error!.localizedErrorMessage(context.l10n)),
          );
          return;
        }
        if (!results.hasData) {
          return;
        }

        RetryManager.dispose('connected_host');

        final connectedHost = results.data;
        final isRunning = results.isRunning;
        context.toast(
          isRunning
              ? const Progress()
              : Text(
                  connectedHost != null
                      ? '${context.l10n.connectedTo}: $connectedHost'
                      : context.l10n.noRadioServerFound,
                ),
          action: connectedHost == null && !isRunning
              ? SnackBarAction(
                  label: context.l10n.tryReconnect,
                  onPressed: () => di<RadioManager>().connectCommand
                      .runRestricted(immediatelyClearErrors: true),
                )
              : null,
        );
      },
    );
  }
}
