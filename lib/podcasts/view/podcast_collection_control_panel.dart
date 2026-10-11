import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/common_control_panel.dart';
import '../../common/view/confirm.dart';
import '../../extensions/build_context_x.dart';
import '../data/podcast_update_capsule.dart';
import '../manager/podcast_collection_filter_manager.dart';
import '../manager/podcast_updates_manager.dart';
import '../manager/subscribed_podcasts_manager.dart';

class PodcastCollectionControlPanel extends ConsumerWidget {
  const PodcastCollectionControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = ref.watch(
      podcastUpdatesManagerProvider.select((s) => s.isRunning),
    );
    final updatesOnly = ref.watch(podcastUpdatesOnlyManagerProvider);
    final downloadsOnly = ref.watch(podcastDownloadsOnlyManagerProvider);

    return CommonControlPanel(
      labels: [
        Text(context.l10n.newEpisodes),
        Text(context.l10n.downloadsOnly),
      ],
      isSelected: [updatesOnly, downloadsOnly],
      onSelected: isRunning
          ? null
          : (index) {
              if (index == 0) {
                if (updatesOnly) {
                  ref
                      .read(podcastUpdatesOnlyManagerProvider.notifier)
                      .setUpdatesOnly(false);
                } else {
                  final subLength =
                      ref
                          .read(subscribedPodcastsManagerProvider)
                          .value
                          ?.length ??
                      0;
                  if (subLength > 10) {
                    ConfirmationDialog.show(
                      context: context,
                      title: Text(context.l10n.checkForUpdates),
                      confirmLabel: context.l10n.checkForUpdates,
                      content: Text(
                        context.l10n.checkForUpdatesConfirm(
                          subLength.toString(),
                        ),
                      ),
                      onConfirm: () => ref
                          .read(podcastUpdatesManagerProvider.notifier)
                          .run(const PodcastUpdateCapsule.updateAll()),
                    );
                  } else {
                    ref
                        .read(podcastUpdatesManagerProvider.notifier)
                        .run(const PodcastUpdateCapsule.updateAll());
                  }
                  ref
                      .read(podcastUpdatesOnlyManagerProvider.notifier)
                      .setUpdatesOnly(true);
                  ref
                      .read(podcastDownloadsOnlyManagerProvider.notifier)
                      .setDownloadsOnly(false);
                }
              } else {
                if (downloadsOnly) {
                  ref
                      .read(podcastDownloadsOnlyManagerProvider.notifier)
                      .setDownloadsOnly(false);
                } else {
                  ref
                      .read(podcastDownloadsOnlyManagerProvider.notifier)
                      .setDownloadsOnly(true);
                  ref
                      .read(podcastUpdatesOnlyManagerProvider.notifier)
                      .setUpdatesOnly(false);
                }
              }
            },
    );
  }
}
