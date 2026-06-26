import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/progress.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../notifications/notifications_service.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../player/manager/player_manager.dart';
import '../../player/service/player_service.dart';
import '../../podcasts/data/podcast_download.dart';
import '../../podcasts/data/podcast_update_capsule.dart';
import '../../podcasts/manager/download_manager.dart';
import '../../podcasts/manager/podcast_clean_manager.dart';
import '../../podcasts/manager/podcast_short_info_manager.dart';
import '../../podcasts/manager/podcast_updates_manager.dart';
import '../app_manager.dart';
import '../sidebar_audios_manager.dart';

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
      select: (PodcastUpdatesManager m) => m.command.results,
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
            if (feedsWithUpdates.length == 1) {
              di<PodcastShortInfoManager>(
                param1: feedsWithUpdates.first,
              ).command.runAsync().then(
                (info) => di<NotificationsService>().notify(
                  message: feedsWithUpdates.length == 1
                      ? '${context.l10n.newEpisodeAvailable} ${info?.name ?? ''}'
                      : '${context.l10n.newEpisodesAvailableFor(feedsWithUpdates.length)}',
                ),
              );
            } else {
              di<NotificationsService>().notify(
                message:
                    '${context.l10n.newEpisodesAvailableFor(feedsWithUpdates.length)}',
              );
            }
          }
        }
      },
    );

    registerStreamHandler(
      select: (PlayerManager m) => m.messageStream,
      handler: (context, newValue, cancel) {
        if (newValue.hasError) {
          final audio = di<PlayerManager>().audio;

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

    registerHandler(
      select: (SidebarAudiosManager m) => m.playAudiosByIdCommand.results,
      handler: (context, results, cancel) {
        if (results.isRunning) {
          context.toast(
            Row(
              spacing: kMediumSpace,
              children: [
                const SizedBox.square(
                  dimension: 16,
                  child: Progress(adaptive: false, strokeWidth: 2),
                ),
                Text(context.l10n.loadingPleaseWait),
              ],
            ),
            duration: const Duration(seconds: 99),
          );
        } else if (results.hasError) {
          context.errorToast(
            results.error.toString(),
            action: SnackBarAction(
              label: '📋',
              onPressed: () => Clipboard.setData(
                ClipboardData(text: results.error.toString()),
              ),
            ),
          );
        } else if (results.hasData && results.data != null) {
          final data = results.data!;
          context.clearToasts();
          di<PlayerManager>().play(audios: data.audios, listName: data.pageId);
        }
      },
    );

    registerHandler(
      select: (PodcastCleanManager m) => m.command.results,
      handler: (context, results, cancel) {
        if (results.isRunning) return;
        if (results.hasError) {
          context.toast(
            Text(results.error.toString()),
            duration: const Duration(seconds: 15),
            showCloseIcon: true,
            action: SnackBarAction(
              label: '📋',
              onPressed: () => Clipboard.setData(
                ClipboardData(text: results.error.toString()),
              ),
            ),
          );
        } else if (results.hasData &&
            results.data != null &&
            results.data!.isNotEmpty) {
          final message = results.data!
              .mapIndexed((index, name) => '${index + 1}. $name')
              .join('\n');
          context.toast(
            Text(
              context.l10n.cleanedUpEpisodesOfUnsubscribedPodcast(
                '\n' + message,
              ),
            ),
            duration: const Duration(seconds: 10),
          );
        }
      },
    );

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
  }
}
