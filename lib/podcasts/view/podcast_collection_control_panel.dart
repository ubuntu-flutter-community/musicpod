import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/common_control_panel.dart';
import '../../common/view/confirm.dart';
import '../../l10n/l10n.dart';
import '../data/podcast_update_capsule.dart';
import '../podcast_manager.dart';

class PodcastCollectionControlPanel extends StatelessWidget with WatchItMixin {
  const PodcastCollectionControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = di<PodcastManager>();

    final updatesOnly = watchValue((PodcastManager m) => m.updatesOnly);
    final downloadsOnly = watchValue((PodcastManager m) => m.downloadsOnly);

    return CommonControlPanel(
      labels: [
        Text(context.l10n.newEpisodes),
        Text(context.l10n.downloadsOnly),
      ],
      isSelected: [updatesOnly, downloadsOnly],
      onSelected: (index) {
        if (index == 0) {
          if (updatesOnly) {
            manager.setUpdatesOnly(false);
          } else {
            final subLength =
                di<PodcastManager>().togglePodcastCommand.value.length;
            if (subLength > 10) {
              ConfirmationDialog.show(
                context: context,
                title: Text(context.l10n.checkForUpdates),
                confirmLabel: context.l10n.checkForUpdates,
                content: Text(context.l10n.checkForUpdatesConfirm(subLength)),
                onConfirm: () => di<PodcastManager>().updatesCommand.runAsync(
                  const PodcastUpdateCapsule.updateAll(),
                ),
              );
            } else {
              di<PodcastManager>().updatesCommand.run(
                const PodcastUpdateCapsule.updateAll(),
              );
            }
            manager.setUpdatesOnly(true);
            manager.setDownloadsOnly(false);
          }
        } else {
          if (downloadsOnly) {
            manager.setDownloadsOnly(false);
          } else {
            manager.setDownloadsOnly(true);
            manager.setUpdatesOnly(false);
          }
        }
      },
    );
  }
}
