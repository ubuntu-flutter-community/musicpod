import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../persistence_utils.dart';

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

class WipeConfirmDialog extends StatefulWidget {
  const WipeConfirmDialog({
    super.key,
  });

  @override
  State<WipeConfirmDialog> createState() => _WipeConfirmDialogState();
}

class _WipeConfirmDialogState extends State<WipeConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ConfirmationDialog(
      showCloseIcon: false,
      title: Text(l10n.confirm),
      content: SizedBox(width: 350, child: Text(l10n.resetAllSettingsConfirm)),
      onConfirm: () => Future.wait([
        wipeCustomSettings(kLikedAudiosFileName),
        wipeCustomSettings(kRadioTagFavsFileName),
        wipeCustomSettings(kCountryFavsFileName),
        wipeCustomSettings(kFavLanguageCodesFileName),
        wipeCustomSettings(kPlaylistsFileName),
        wipeCustomSettings(kPinnedAlbumsFileName),
        wipeCustomSettings(kPodcastsFileName),
        wipeCustomSettings(kPodcastsUpdates),
        wipeCustomSettings(kStarredStationsFileName),
        wipeCustomSettings(kSettingsFileName),
        wipeCustomSettings(kLastPositionsFileName),
        wipeCustomSettings(kPlayerStateFileName),
        wipeCustomSettings(kAppStateFileName),
        wipeCustomSettings(kRadioHistoryFileName),
      ]).then((_) => exit(0)),
    );
  }
}
