import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_manager.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../custom_content/view/backup_dialog.dart';
import '../../extensions/build_context_x.dart';
import '../manager/wipe_manager.dart';

class ResetSection extends StatelessWidget {
  const ResetSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    return YaruSection(
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
              onPressed: () => context.dialog((context) {
                di<AppManager>().resetBackupSettings();
                return const BackupDialog(breakingChange: false);
              }, barrierDismissible: false),
              child: Text(l10n.export),
            ),
          ),
          YaruTile(
            leading: Icon(Iconz.remove),
            title: Text(l10n.resetAllSettings),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              onPressed: () => context.dialog(
                (context) => const WipeConfirmDialog(),
                barrierDismissible: false,
              ),
              child: Text(
                l10n.reset,
                style: TextStyle(color: theme.colorScheme.onError),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WipeConfirmDialog extends StatelessWidget {
  const WipeConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ConfirmationDialog(
      showCloseIcon: false,
      title: Text(l10n.confirm),
      content: SizedBox(width: 350, child: Text(l10n.resetAllSettingsConfirm)),
      onConfirm: () => di<WipeManager>().wipeCommand.runAsync(),
    );
  }
}
