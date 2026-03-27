import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/confirm.dart';
import '../../common/view/ui_constants.dart';
import '../custom_content_model.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../app/app_manager.dart';

class BackupDialog extends StatelessWidget with WatchItMixin {
  const BackupDialog({super.key, this.breakingChange = true});

  final bool breakingChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final appManager = di<AppManager>();
    final radioBackup = watchValue((AppManager m) => m.radioBackup);
    final localAudioBackup = watchValue((AppManager m) => m.localAudioBackup);
    final podcastBackup = watchValue((AppManager m) => m.podcastBackup);
    final confirmEnabled = radioBackup && localAudioBackup && podcastBackup;

    return ConfirmationDialog(
      showCancel: false,
      showCloseIcon: !breakingChange,
      confirmEnabled: confirmEnabled,
      onConfirm: () => appManager.setBackupSaved(true),
      title: Text(
        breakingChange
            ? l10n.breakingChangesPleaseBackupTitle
            : l10n.exportYourData,
      ),
      content: SizedBox(
        height: 500,
        width: 450,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: kLargestSpace,
          children: [
            if (breakingChange) ...[
              Text(context.l10n.breakingChangesPleaseBackupDescription),
              const Divider(),
              Text(
                context.l10n.breakingChangesPleaseBackupConfirmation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            Flexible(
              child: YaruExpansionPanel(
                key: ValueKey('$podcastBackup$localAudioBackup$radioBackup'),
                collapseOnExpand: false,
                shrinkWrap: true,
                isInitiallyExpanded: AudioType.values
                    .map(
                      (e) => switch (e) {
                        AudioType.local => !localAudioBackup,
                        AudioType.podcast => !podcastBackup,
                        AudioType.radio => !radioBackup,
                      },
                    )
                    .toList(),
                headers: AudioType.values
                    .map(
                      (e) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.localizedBackupName(l10n)),
                          CommonCheckBox(
                            value: switch (e) {
                              AudioType.podcast => podcastBackup,
                              AudioType.local => localAudioBackup,
                              AudioType.radio => radioBackup,
                            },
                            onChanged: (v) => switch (e) {
                              AudioType.podcast => appManager.setPodcastBackup(
                                v ?? false,
                              ),
                              AudioType.local => appManager.setLocalAudioBackup(
                                v ?? false,
                              ),
                              AudioType.radio => appManager.setRadioBackup(
                                v ?? false,
                              ),
                            },
                          ),
                        ],
                      ),
                    )
                    .toList(),
                children: AudioType.values
                    .map(
                      (e) => switch (e) {
                        AudioType.local => _Section(
                          children: [
                            YaruTile(
                              title: ElevatedButton(
                                onPressed: () {
                                  di<CustomContentModel>()
                                      .exportPlaylistsAndPinnedAlbumsToM3Us()
                                      .then(
                                        (v) =>
                                            appManager.setLocalAudioBackup(v),
                                      );
                                },
                                child: Text(
                                  l10n.exportPlaylistsAndAlbumsToM3UFiles,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AudioType.podcast => _Section(
                          children: [
                            YaruTile(
                              title: ElevatedButton(
                                child: Text(l10n.exportPodcastsToOpmlFile),
                                onPressed: () => di<CustomContentModel>()
                                    .exportPodcastsToOpmlFile()
                                    .then(
                                      (v) => appManager.setPodcastBackup(v),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        AudioType.radio => _Section(
                          children: [
                            YaruTile(
                              title: ElevatedButton(
                                onPressed: () => di<CustomContentModel>()
                                    .exportStarredStationsToOpmlFile()
                                    .then((v) => appManager.setRadioBackup(v)),
                                child: Text(
                                  l10n.exportStarredStationsToOpmlFile,
                                ),
                              ),
                            ),
                          ],
                        ),
                      },
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: kMediumSpace,
        right: kMediumSpace,
        bottom: kMediumSpace,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
