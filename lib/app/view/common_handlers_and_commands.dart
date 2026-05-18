import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../custom_content/view/backup_dialog.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../player/player_model.dart';
import '../../player/player_service.dart';
import '../../podcasts/podcast_manager.dart';
import '../app_manager.dart';

mixin CommonHandlersAndCommandsMixin {
  void setupCommonHandlersAndCommands(BuildContext context) {
    registerStreamHandler(
      select: (PodcastManager m) => m.downloadStream,
      handler: (context, asyncData, cancel) {
        if (!asyncData.hasData) return;
        final result = asyncData.data!;
        context.toast(
          Text(switch (result) {
            final PodcastDownloadResult r
                when r.status == PodcastDownloadStatus.downloaded =>
              context.l10n.downloadFinished(r.audio.title ?? ''),
            final PodcastDownloadResult r
                when r.status == PodcastDownloadStatus.removed =>
              context.l10n.downloadRemoved(r.audio.title ?? ''),
            final PodcastDownloadResult r
                when r.status == PodcastDownloadStatus.cancelled =>
              context.l10n.downloadCancelled(r.audio.title ?? ''),
            _ => '',
          }),
        );
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
