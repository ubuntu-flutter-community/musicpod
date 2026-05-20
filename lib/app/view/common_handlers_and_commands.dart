import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../custom_content/view/backup_dialog.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../notifications/notifications_service.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../player/player_model.dart';
import '../../player/player_service.dart';
import '../../podcasts/data/podcast_download.dart';
import '../../podcasts/download_manager_master.dart';
import '../../podcasts/podcast_manager.dart';
import '../app_manager.dart';

mixin CommonHandlersAndCommandsMixin {
  void setupCommonHandlersAndCommands(BuildContext context) {
    registerStreamHandler(
      select: (DownloadManagerMaster m) => m.downloadStream,
      handler: (context, asyncData, cancel) {
        if (!asyncData.hasData ||
            asyncData.data?.status == DownloadStatus.inProgress)
          return;
        final result = asyncData.data!;
        context.toast(
          Text(switch (result) {
            final PodcastDownload r when r.status == DownloadStatus.completed =>
              context.l10n.downloadFinished(r.audio.title ?? ''),
            final PodcastDownload r when r.status == DownloadStatus.removed =>
              context.l10n.downloadRemoved(r.audio.title ?? ''),
            final PodcastDownload r when r.status == DownloadStatus.cancelled =>
              context.l10n.downloadCancelled(r.audio.title ?? ''),
            _ => '',
          }),
        );
      },
    );

    registerHandler(
      select: (PodcastManager m) => m.updatesCommand,
      handler: (context, feedsWithUpdates, cancel) {
        if (feedsWithUpdates.isEmpty) {
        } else {
          di<NotificationsService>().notify(
            message: feedsWithUpdates.length == 1
                ? '${context.l10n.newEpisodeAvailable} ${di<PodcastManager>().getSubscribedPodcastName(feedsWithUpdates.first)}'
                : '${context.l10n.newEpisodesAvailableFor(feedsWithUpdates.length)}',
          );
        }
      },
    );

    registerStreamHandler(
      select: (PlayerModel m) => m.errorStream,
      handler: (context, newValue, cancel) {
        if (newValue.hasData)
          context.toast(
            Text(switch (newValue.data!) {
              final PlayTimeoutException _ => context.l10n.playingMediaTimedOut,
              final Exception e => e.toString(),
            }),
          );
      },
    );

    registerStreamHandler(
      select: (PlayerModel m) => m.messageStream,
      handler: (context, newValue, cancel) {
        if (newValue.hasData) context.toast(Text(newValue.data!));
      },
    );

    callOnceAfterThisBuild((context) {
      final appManager = di<AppManager>();
      appManager.backupNeededCommand.run();
      appManager.recentPatchNotesDisposedCommand.run();
    });

    registerHandler(
      select: (AppManager m) => m.recentPatchNotesDisposedCommand,
      handler: (context, newValue, cancel) {
        if (newValue == false) {
          context.dialog((context) => const PatchNotesDialog());
        }
      },
    );

    registerHandler(
      select: (AppManager m) => m.backupNeededCommand,
      handler: (context, newValue, cancel) {
        if (newValue == true) {
          context.dialog(
            (context) => const BackupDialog(),
            barrierDismissible: false,
          );
        }
      },
    );
  }
}
