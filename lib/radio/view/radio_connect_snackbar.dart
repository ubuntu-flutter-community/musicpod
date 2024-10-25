import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/snackbars.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';

SnackBar buildConnectSnackBar({
  required String? connectedHost,
  required BuildContext context,
}) =>
    SnackBar(
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
