import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../constants.dart';
import '../../../get.dart';
import '../../../l10n.dart';
import '../../theme.dart';
import '../settings_model.dart';
import 'settings_dialog.dart';

class SettingsButton extends StatelessWidget with WatchItMixin {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final model = getIt<SettingsModel>();
    final popupMenuButton = PopupMenuButton(
      padding: yaruStyled ? EdgeInsets.zero : const EdgeInsets.all(8.0),
      tooltip: context.l10n.moreOptions,
      icon: Icon(Iconz().menu),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Center(
            child: ImportantButton(
              onPressed: () {
                Navigator.of(context).pop();
                model.playOpenedFile();
              },
              child: Text(context.l10n.open),
            ),
          ),
        ),
        PopupMenuItem(
          enabled: false,
          child: Center(
            child: TextButton(
              child: Text(context.l10n.settings),
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => const SettingsDialog(),
                );
              },
            ),
          ),
        ),
      ],
    );

    if (!model.allowManualUpdate) return popupMenuButton;

    final updateAvailable =
        watchPropertyValue((SettingsModel m) => m.updateAvailable);

    if (updateAvailable == null) {
      return Center(
        child: SizedBox.square(
          dimension: yaruStyled ? kYaruTitleBarItemHeight : 40,
          child: const Progress(
            padding: EdgeInsets.all(10),
          ),
        ),
      );
    } else {
      if (updateAvailable) {
        return IconButton(
          tooltip: context.l10n.updateAvailable,
          onPressed: () => launchUrl(
            Uri.parse(
              p.join(
                kRepoUrl,
                'releases',
                'tag',
                model.onlineVersion,
              ),
            ),
          ),
          icon: Icon(
            Iconz().updateAvailable,
            color: context.t.colorScheme.success,
          ),
        );
      } else {
        return popupMenuButton;
      }
    }
  }
}
