import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/app_manager.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/view/backup_dialog.dart';
import '../../extensions/build_context_x.dart';
import '../manager/wipe_manager.dart';
import 'settings_list_tile.dart';
import 'settings_section.dart';

class ResetSection extends StatelessWidget {
  const ResetSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    return SettingsSection(
      heading: l10n.resetAllSettings,
      children: [
        SettingsListTile(
          position: ListTilePosition.first,
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
        SettingsListTile(
          position: ListTilePosition.last,
          leading: Icon(Iconz.remove),
          title: Text(l10n.resetAllSettings),
          subtitle: Text(l10n.resetAllSettings),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () => ConfirmationDialog.show(
              context: context,
              modalLevel: ModalLevel.error,
              barrierDismissible: false,
              title: Text(l10n.confirm),
              content: Padding(
                padding: const EdgeInsets.all(kMediumPlusSpace),
                child: Text(l10n.resetAllSettingsConfirm),
              ),
              onConfirm: () => di<WipeManager>().command.runAsync(),
            ),
            child: Text(
              l10n.reset,
              style: TextStyle(color: theme.colorScheme.onError),
            ),
          ),
        ),
      ],
    );
  }
}
