import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/confirm.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../manager/backup_manager.dart';
import '../service/custom_content_service.dart';

class BackupDialog extends ConsumerWidget {
  const BackupDialog({super.key, this.breakingChange = true});

  final bool breakingChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = context.theme;
    final backupState = ref.watch(backupManagerProvider);
    final backupNotifier = ref.read(backupManagerProvider.notifier);
    final radioBackup = backupState.radio;
    final localAudioBackup = backupState.localAudio;
    final podcastBackup = backupState.podcast;
    final confirmEnabled = backupState.confirmEnabled;

    return ConfirmationDialog(
      showCancel: false,
      barrierDismissible: !breakingChange,
      onConfirm: confirmEnabled ? () => backupNotifier.setBackupSaved(true) : null,
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
                              AudioType.podcast => backupNotifier.setPodcast(
                                v ?? false,
                              ),
                              AudioType.local => backupNotifier.setLocalAudio(
                                v ?? false,
                              ),
                              AudioType.radio => backupNotifier.setRadio(
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
                            ListTile(
                              title: ElevatedButton(
                                onPressed: () {
                                  di<CustomContentService>()
                                      .exportPlaylistsAndPinnedAlbumsToM3Us()
                                      .then(
                                        (v) =>
                                            backupNotifier.setLocalAudio(v),
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
                            ListTile(
                              title: ElevatedButton(
                                child: Text(l10n.exportPodcastsToOpmlFile),
                                onPressed: () => di<CustomContentService>()
                                    .exportPodcastsToOpmlFile()
                                    .then(
                                      (v) => backupNotifier.setPodcast(v),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        AudioType.radio => _Section(
                          children: [
                            ListTile(
                              title: ElevatedButton(
                                onPressed: () => di<CustomContentService>()
                                    .exportStarredStationsToOpmlFile()
                                    .then((v) => backupNotifier.setRadio(v)),
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
