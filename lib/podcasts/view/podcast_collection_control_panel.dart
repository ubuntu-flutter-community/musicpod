import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/connectivity_manager.dart';
import '../../common/view/common_control_panel.dart';
import '../../common/view/confirm.dart';
import '../../common/view/offline_page.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../podcast_manager.dart';

class PodcastCollectionControlPanel extends StatelessWidget with WatchItMixin {
  const PodcastCollectionControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = di<PodcastManager>();

    final isOnline = watchValue(
      (ConnectivityManager m) =>
          m.connectivityCommand.select((p) => p.isOnline),
    );
    if (!isOnline) return const OfflineBody();

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
            if (di<LibraryModel>().podcastsLength > 10) {
              ConfirmationDialog.show(
                context: context,
                title: Text(context.l10n.checkForUpdates),
                confirmLabel: context.l10n.checkForUpdates,
                content: Text(
                  context.l10n.checkForUpdatesConfirm(
                    di<LibraryModel>().podcastsLength.toString(),
                  ),
                ),
                onConfirm: () => di<PodcastManager>().checkForUpdates(
                  updateMessage: context.l10n.newEpisodeAvailable,
                  multiUpdateMessage: (length) => context.mounted
                      ? context.l10n.newEpisodesAvailableFor(length)
                      : context.l10n.newEpisodeAvailable,
                ),
              );
            } else {
              showFutureLoadingDialog(
                context: context,
                backLabel: context.l10n.back,
                title: context.l10n.loadingPleaseWait,
                future: () => di<PodcastManager>().checkForUpdates(
                  updateMessage: context.l10n.newEpisodeAvailable,
                  multiUpdateMessage: (length) => context.mounted
                      ? context.l10n.newEpisodesAvailableFor(length)
                      : context.l10n.newEpisodeAvailable,
                ),
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
