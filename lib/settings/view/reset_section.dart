import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/view/backup_dialog.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../settings_model.dart';

class ResetSection extends StatelessWidget {
  const ResetSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    return YaruSection(
      margin: const EdgeInsets.only(
        left: kLargestSpace,
        top: kLargestSpace,
        right: kLargestSpace,
      ),
      headline: Text(l10n.resetAllSettings),
      child: Column(
        children: [
          YaruTile(
            leading: Icon(Iconz.download),
            title: Text(l10n.exportYourData),
            subtitle: SizedBox(
              width: 300,
              child: Text(l10n.exportYourDataDescription),
            ),
            trailing: ElevatedButton(
              onPressed: () => showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  di<AppModel>().resetBackupSettings();
                  return const BackupDialog(breakingChange: false);
                },
              ),
              child: Text(
                l10n.export,
              ),
            ),
          ),
          YaruTile(
            leading: Icon(Iconz.remove),
            title: Text(l10n.resetAllSettings),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              onPressed: () => showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => const WipeConfirmDialog(),
              ),
              child: Text(
                l10n.reset,
                style: TextStyle(
                  color: theme.colorScheme.onError,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WipeConfirmDialog extends StatelessWidget {
  const WipeConfirmDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ConfirmationDialog(
      showCloseIcon: false,
      title: Text(l10n.confirm),
      content: SizedBox(width: 350, child: Text(l10n.resetAllSettingsConfirm)),
      onConfirm: () => di<SettingsModel>().wipeAllSettings(),
    );
  }
}
