import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/build_context_x.dart';
import '../manager/radio_manager.dart';

mixin RadioConnectMixin {
  void registerRadioConnectHandler(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<String?>>(
      radioManagerProvider,
      (previous, next) {
        if (next.isLoading) return;

        final connectedHost = next.value;
        final hasError = next.hasError;
        context.toast(
          Text(
            connectedHost != null
                ? '${context.l10n.connectedTo}: $connectedHost'
                : context.l10n.noRadioServerFound,
          ),
          action: (connectedHost == null || hasError)
              ? SnackBarAction(
                  label: context.l10n.tryReconnect,
                  onPressed: () =>
                      ref.read(radioManagerProvider.notifier).reconnect(),
                )
              : null,
        );
      },
    );
  }
}
