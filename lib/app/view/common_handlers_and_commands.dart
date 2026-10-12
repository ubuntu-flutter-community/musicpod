import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:package_info_plus/package_info_plus.dart';

import '../../common/view/audio_page_type.dart';
import '../../common/view/confirm.dart';
import '../../common/view/progress.dart';
import '../../common/view/ui_constants.dart';
import '../../dependencies.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/object_x.dart';
import '../../notifications/notifications_service.dart';
import '../../patch_notes/manager/recent_patch_notes_disposed_manager.dart';
import '../../patch_notes/manager/special_notes_disposed_manager.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../patch_notes/special_notes.dart';
import '../../player/data/play_timeout_exception.dart';
import '../../player/manager/current_audio_manager.dart';
import '../../player/manager/player_message_manager.dart';
import '../../podcasts/data/podcast_download.dart';
import '../../podcasts/data/podcast_update_capsule.dart';
import '../../podcasts/manager/download_manager.dart';
import '../../external_path/manager/secure_bookmark_manager.dart';
import '../../podcasts/manager/podcast_clean_manager.dart';
import '../../podcasts/service/podcast_service.dart';
import '../../podcasts/manager/podcast_updates_manager.dart';
import '../../radio/manager/click_station_manager.dart';
import '../data/play_anywhere_result.dart';
import '../play_anywhere_manager.dart';

mixin CommonHandlersAndCommandsMixin {
  void callCommonCommands(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      container
          .read(podcastCleanManagerProvider.notifier)
          .clean(reclaimDiskSpace: true);

      if (!container.read(recentPatchNotesDisposedManagerProvider)) {
        PatchNotesDialog.show(context);
      }

      final version = di<PackageInfo>().version;
      if (!container.read(specialNotesDisposedManagerProvider) &&
          specialNotes[version] != null) {
        ConfirmationDialog.show(
          context: context,
          barrierDismissible: false,
          showCancel: false,
          title: Text('Special notes for $version'),
          content: Text(specialNotes[version]!),
          confirmLabel: context.l10n.ok,
          onConfirm: () => container
              .read(specialNotesDisposedManagerProvider.notifier)
              .disposeNotes(),
        );
      }

      container.read(secureBookmarkManagerProvider.notifier).restore();
    });
  }

  void registerCommonHandlers(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);

    container.listen<AsyncValue<DownloadManagerState>>(
      downloadManagerProvider,
      (prev, next) {
        final result = next.value?.lastEvent;
        if (result == null ||
            result == prev?.value?.lastEvent ||
            result.status == DownloadStatus.inProgress) {
          return;
        }
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

    container.listen<AsyncValue<String>>(
      playerMessageProvider,
      (prev, next) {
        if (next.hasError) {
          final audio = container.read(currentAudioManagerProvider);
          final error = next.error;

          context.toast(
            Text(
              (error is PlayTimeoutException) || audio?.url != null
                  ? context.l10n.playerCouldNotOpenRemoteMedia(
                      audio?.title ?? '',
                    )
                  : error.toString(),
            ),
            duration: const Duration(seconds: 8),
            showCloseIcon: true,
          );
        } else if (next.hasValue && next.value != null) {
          context.toast(Text(next.value!));
        }
      },
    );

    container.listen<AsyncValue<PlayAnywhereResult?>>(
      playAnywhereManagerProvider,
      (prev, next) {
        if (next.isLoading) {
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
        } else if (next.hasError) {
          context.toast(
            Text(next.error.localizedErrorMessage(context.l10n)),
          );
        } else if (next.hasValue && next.value != null) {
          context.clearToasts();
          switch (next.value!.param.audioPageType) {
            case AudioPageType.radio:
              next.value!.audios.singleOrNull?.uuid != null
                  ? container
                      .read(clickStationManagerProvider.notifier)
                      .clickStation(
                        next.value!.audios.singleOrNull!.uuid,
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
  }
}
