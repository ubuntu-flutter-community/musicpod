import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common/view/ui_constants.dart';
import '../../custom_content/view/backup_dialog.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../notifications/notifications_service.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../player/player_model.dart';
import '../../player/player_service.dart';
import '../../podcasts/data/podcast_download.dart';
import '../../podcasts/data/podcast_update_capsule.dart';
import '../../podcasts/download_manager.dart';
import '../../podcasts/podcast_manager.dart';
import '../../search/search_manager.dart';
import '../../search/search_timeout_exception.dart';
import '../app_manager.dart';

mixin CommonHandlersAndCommandsMixin {
  void setupCommonHandlersAndCommands(BuildContext context) {
    registerStreamHandler(
      select: (DownloadManager m) => m.downloadStream,
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
      select: (PodcastManager m) => m.manageUpdatesCommand.results,
      handler: (context, res, cancel) {
        if (res.isRunning) {
          return;
        } else if (res.hasError) {
          context.toast(Text(res.error.toString()));
        } else if (res.paramData?.type == PodcastUpdateType.remove) {
          return;
        } else if (res.hasData) {
          final feedsWithUpdates = res.data ?? {};
          if (feedsWithUpdates.isEmpty) {
          } else {
            di<NotificationsService>().notify(
              message: feedsWithUpdates.length == 1
                  ? '${context.l10n.newEpisodeAvailable} ${di<PodcastManager>().getSubscribedPodcastName(feedsWithUpdates.first)}'
                  : '${context.l10n.newEpisodesAvailableFor(feedsWithUpdates.length)}',
            );
          }
        }
      },
    );

    registerStreamHandler(
      select: (PlayerModel m) => m.messageStream,
      handler: (context, newValue, cancel) {
        if (newValue.hasError) {
          final audio = di<PlayerModel>().audio;

          context.toast(
            Text(
              (newValue.error is PlayTimeoutException) || audio?.url != null
                  ? context.l10n.playerCouldNotOpenRemoteMedia(
                      audio?.title ?? '',
                    )
                  : newValue.error.toString(),
            ),
            duration: const Duration(seconds: 8),
            showCloseIcon: true,
          );
        } else if (newValue.hasData) {
          context.toast(Text(newValue.data!));
        }
      },
    );

    registerStreamHandler(
      select: (SearchManager m) => m.messageStream,
      handler: (context, newValue, cancel) {
        if (newValue.hasError) {
          context.toast(
            Text(switch (newValue.error) {
              SearchTimeoutException() => context.l10n.searchTimeoutMessage,
              PodcastFailedException() =>
                (newValue.error as PodcastFailedException).message,
              _ => newValue.error.toString(),
            }),
            duration: const Duration(seconds: 8),
            showCloseIcon: true,
          );
        }
      },
    );

    registerHandler(
      select: (PodcastManager m) => m.cleanUpCommand,
      handler: (context, name, cancel) {
        if (name != null) {
          context.toast(
            Text(
              '${context.l10n.cleanedUpEpisodesOfUnsubscribedPodcast(name)}',
            ),
          );
        }
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
          if (isMobile) {
            context.bottomSheet(
              (context) => const PatchNotesDialog(
                insetPadding: EdgeInsets.all(kMediumSpace),
                contentPadding: EdgeInsets.all(kMediumSpace),
                actionsPadding: EdgeInsets.all(kMediumSpace),
              ),
            );
          } else {
            context.dialog((context) => const PatchNotesDialog());
          }
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
