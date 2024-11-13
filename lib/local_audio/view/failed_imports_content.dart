import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/snackbars.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../settings/settings_model.dart';

class FailedImportsContent extends StatelessWidget {
  const FailedImportsContent({
    super.key,
    required this.failedImports,
    required this.onNeverShowFailedImports,
  });

  final List<String> failedImports;
  final void Function() onNeverShowFailedImports;

  @override
  Widget build(BuildContext context) {
    final textColor = context.theme.snackBarTheme.actionTextColor;
    return SizedBox(
      height: 400,
      width: 400,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    context.l10n.failedToImport,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  onNeverShowFailedImports();
                  ScaffoldMessenger.of(context).clearSnackBars();
                },
                child: Text(
                  context.l10n.dontShowAgain,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: failedImports.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    failedImports[index],
                    style: TextStyle(color: textColor),
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

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
    showFailedImportsSnackBar({
  required List<String> failedImports,
  required BuildContext context,
}) {
  final settingsModel = di<SettingsModel>();
  if (settingsModel.neverShowFailedImports) return null;
  return showSnackBar(
    context: context,
    content: FailedImportsContent(
      failedImports: failedImports,
      onNeverShowFailedImports: () =>
          settingsModel.setNeverShowFailedImports(true),
    ),
  );
}
