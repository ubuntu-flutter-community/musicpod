import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../settings_model.dart';

class ResetSection extends StatelessWidget {
  const ResetSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            leading: Icon(Iconz.remove),
            title: Text(l10n.resetAllSettings),
            trailing: ImportantButton(
              onPressed: () => showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => const WipeConfirmDialog(),
              ),
              child: Text(
                l10n.resetAllSettings,
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
      onConfirm: di<SettingsModel>().wipeAllSettings,
    );
  }
}
