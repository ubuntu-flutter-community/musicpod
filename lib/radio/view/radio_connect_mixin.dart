import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../radio_manager.dart';
import '../radio_service.dart';

mixin RadioConnectMixin {
  void registerRadioConnectHandler(BuildContext context) {
    registerHandler(
      select: (RadioManager m) => m.connectCommand.results,
      handler: (context, results, cancel) {
        if (results.hasError) {
          context.toast(
            Text(switch (results.error) {
              final e when e is FindStationTimeoutException =>
                context.l10n.findStationsTimeoutMessage,
              final e when e is RadioBrowserServerUnavailableException =>
                context.l10n.radioBrowserSeverUnavailable,
              _ => results.error.toString(),
            }),
          );
          return;
        }
        if (!results.hasData) {
          return;
        }
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
                  onPressed: di<RadioManager>().connectCommand,
                )
              : null,
        );
      },
    );
  }
}
