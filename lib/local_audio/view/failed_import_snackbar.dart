import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/snackbars.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../settings/settings_model.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
    showFailedImportsSnackBar({
  required List<String> failedImports,
  required BuildContext context,
  required String message,
}) {
  final settingsModel = di<SettingsModel>();
  if (settingsModel.neverShowFailedImports) return null;
  return showSnackBar(
    context: context,
    content: _Content(
      message: message,
      failedImports: failedImports,
      onNeverShowFailedImports: () =>
          settingsModel.setNeverShowFailedImports(true),
    ),
    action: SnackBarAction(
      onPressed: () {
        settingsModel.setNeverShowFailedImports(true);
        ScaffoldMessenger.of(context).clearSnackBars();
      },
      label: context.l10n.dontShowAgain,
    ),
  );
}

class _Content extends StatelessWidget {
  const _Content({
    required this.failedImports,
    required this.onNeverShowFailedImports,
    required this.message,
  });

  final String message;
  final List<String> failedImports;
  final void Function() onNeverShowFailedImports;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textColor = theme.snackBarTheme.backgroundColor == null
        ? theme.colorScheme.primary
        : contrastColor(theme.snackBarTheme.backgroundColor!);
    return SizedBox(
      height: 200,
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: textColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: failedImports.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    failedImports[index],
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
