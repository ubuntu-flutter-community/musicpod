import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/audio_page_type.dart';
import '../../common/view/confirm.dart';
import '../../common/view/progress.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/object_x.dart';
import '../../notifications/notifications_service.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../patch_notes/special_notes.dart';
import '../../player/data/play_timeout_exception.dart';
import '../../player/manager/player_manager.dart';
import '../../podcasts/data/podcast_download.dart';
import '../../podcasts/data/podcast_update_capsule.dart';
import '../../podcasts/manager/download_manager.dart';
import '../../external_path/manager/secure_bookmark_manager.dart';
import '../../podcasts/manager/podcast_clean_manager.dart';
import '../../podcasts/service/podcast_service.dart';
import '../../podcasts/manager/podcast_updates_manager.dart';
import '../../radio/manager/click_station_manager.dart';
import '../app_manager.dart';
import '../play_anywhere_manager.dart';

mixin CommonHandlersAndCommandsMixin {
  void callCommonCommands(BuildContext context) => callOnceAfterThisBuild((_) {
    ProviderScope.containerOf(context, listen: false)
        .read(podcastCleanManagerProvider.notifier)
        .clean(reclaimDiskSpace: true);
    di<AppManager>().recentPatchNotesDisposedCommand.run();
    di<AppManager>().specialNotesDisposedCommand.run();
    di<SecureBookmarkManager>().command.run();
  });

  void registerCommonHandlers(BuildContext context) {
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

    final container = ProviderScope.containerOf(context, listen: false);

    container.listen<PodcastUpdatesState>(podcastUpdatesManagerProvider, (prev, res) {
      if (res.isRunning) {
        return;
      } else if (res.error != null) {
        context.toast(Text(res.error.toString()));
      } else if (res.lastCapsule?.type == PodcastUpdateType.remove) {
        return;
      } else {
        final feedsWithUpdates = res.updates;
        if (feedsWithUpdates.isNotEmpty) {
          if (feedsWithUpdates.length == 1) {
            di<PodcastService>()
                .getPodcastShortInfo(feedsWithUpdates.entries.first.key)
                .then(
              (info) => di<NotificationsService>().notify(
                message:
                    '${context.l10n.newEpisodeAvailable} ${info?.name ?? ''}',
              ),
            );
          } else {
            di<NotificationsService>().notify(
              message:
                  context.l10n.newEpisodesAvailableFor(feedsWithUpdates.length),
            );
          }
        }
      }
    });

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
      select: (PlayAnywhereManager m) => m.command.results,
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
          context.toast(
            Text(results.error.localizedErrorMessage(context.l10n)),
          );
        } else if (results.hasData && results.data != null) {
          context.clearToasts();
          switch (results.data!.param.audioPageType) {
            case AudioPageType.radio:
              results.data!.audios.singleOrNull?.uuid != null
                  ? di<ProviderContainer>()
                      .read(clickStationManagerProvider.notifier)
                      .clickStation(
                        results.data!.audios.singleOrNull!.uuid,
                      )
                  : context.toast(Text(context.l10n.noStationFound));
            default:
              break;
          }
        }
      },
    );

    container.listen<AsyncValue<Set<String>?>>(podcastCleanManagerProvider, (prev, results) {
      if (results.isLoading) return;
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
      } else if (results.hasValue &&
          results.value != null &&
          results.value!.isNotEmpty) {
        final message = results.value!
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
    });

    registerHandler(
      select: (AppManager m) => m.recentPatchNotesDisposedCommand,
      handler: (context, newValue, cancel) {
        if (newValue == false) {
          PatchNotesDialog.show(context);
        }
      },
    );

    registerHandler(
      select: (AppManager m) => m.specialNotesDisposedCommand,
      handler: (context, newValue, cancel) {
        if (newValue == false &&
            specialNotes[di<AppManager>().version] != null) {
          final appManager = di<AppManager>();
          ConfirmationDialog.show(
            context: context,
            barrierDismissible: false,
            showCancel: false,
            title: Text('Special notes for ${appManager.version}'),
            content: Text(specialNotes[appManager.version]!),
            confirmLabel: context.l10n.ok,
            onConfirm: () => appManager.disposeSpecialNotes(),
          );
        }
      },
    );
  }
}
