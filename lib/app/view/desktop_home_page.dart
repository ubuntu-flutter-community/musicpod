import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:watcher/watcher.dart';

import '../../common/view/confirm.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/view/backup_dialog.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../player/player_model.dart';
import '../../player/view/player_view.dart';
import '../../podcasts/download_model.dart';
import '../../settings/settings_model.dart';
import '../app_model.dart';
import '../connectivity_model.dart';
import 'master_detail_page.dart';

class DesktopHomePage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  @override
  void initState() {
    super.initState();
    final appModel = di<AppModel>();
    appModel
        .checkForUpdate(isOnline: di<ConnectivityModel>().isOnline == true)
        .then((_) {
          if (!appModel.recentPatchNotesDisposed() && mounted) {
            showDialog(
              context: context,
              builder: (_) => PatchNotesDialog(
                onClose: () {
                  if ((di<LocalAudioModel>().audios?.isNotEmpty ?? false) &&
                      di<LibraryModel>().playlistIDs.isNotEmpty &&
                      di<LibraryModel>().favoriteAlbums.isNotEmpty &&
                      di<AppModel>().isBackupScreenNeeded &&
                      !di<AppModel>().wasBackupSaved &&
                      mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const BackupDialog(),
                    );
                  }
                },
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final autoMovePlayer = watchPropertyValue(
      (SettingsModel m) => m.autoMovePlayer,
    );
    final playerToTheRight =
        autoMovePlayer && context.mediaQuerySize.width > kSideBarThreshHold;
    final isInFullWindowMode = watchPropertyValue(
      (AppModel m) => m.fullWindowMode ?? false,
    );
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo == true);

    registerStreamHandler(
      select: (AppModel m) => m.isDiscordConnectedStream,
      handler: discordConnectedHandler,
    );

    registerStreamHandler(
      select: (DownloadModel m) => m.messageStream,
      handler: downloadMessageStreamHandler,
    );
    registerStreamHandler(
      select: (LocalAudioModel m) =>
          m.fileWatcher?.events ?? const Stream<WatchEvent>.empty(),
      handler: (context, newValue, cancel) {
        final l10n = context.l10n;

        if (newValue.hasData && !di<LocalAudioModel>().importing) {
          showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: Text(l10n.localAudioWatchDialogTitle),
              content: Text(l10n.localAudioWatchDialogDescription),
              onConfirm: () async {
                await di<LocalAudioModel>().init(forceInit: true);
              },
            ),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: isVideo ? Colors.black : null,
      body: isInFullWindowMode
          ? const PlayerView.fullWindow()
          : Row(
              children: [
                const Expanded(child: const MasterDetailPage()),
                if (playerToTheRight)
                  const SizedBox(
                    width: kSideBarPlayerWidth,
                    child: PlayerView.sideBar(),
                  ),
              ],
            ),
      bottomNavigationBar: !playerToTheRight && !isInFullWindowMode
          ? const PlayerView.bottom()
          : null,
    );
  }
}
