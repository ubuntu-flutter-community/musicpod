import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/view/backup_dialog.dart';
import '../../extensions/build_context_x.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../player/player_model.dart';
import '../../player/view/player_view.dart';
import '../../podcasts/download_model.dart';
import '../../podcasts/podcast_model.dart';
import '../../podcasts/view/podcast_state_stream_handler.dart';
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
        .checkForUpdate(
      isOnline: di<ConnectivityModel>().isOnline == true,
    )
        .then((_) {
      if (!appModel.recentPatchNotesDisposed() && mounted) {
        showDialog(
          context: context,
          builder: (_) => PatchNotesDialog(
            onClose: () {
              if ((di<LocalAudioModel>().audios?.isNotEmpty ?? false) &&
                  di<LibraryModel>().playlists.isNotEmpty &&
                  di<LibraryModel>().pinnedAlbums.isNotEmpty &&
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
    final playerToTheRight = context.mediaQuerySize.width > kSideBarThreshHold;
    final isFullScreen = watchPropertyValue((AppModel m) => m.fullWindowMode);
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
      select: (PodcastModel m) => m.stateStream,
      handler: podcastStateStreamHandler,
    );

    registerStreamHandler(
      select: (ConnectivityModel m) => m.onConnectivityChanged,
      handler: onConnectivityChangedHandler,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Expanded(child: MasterDetailPage()),
                  if (!playerToTheRight || AppConfig.isMobilePlatform)
                    const PlayerView(position: PlayerPosition.bottom),
                ],
              ),
            ),
            if (playerToTheRight)
              const SizedBox(
                width: kSideBarPlayerWidth,
                child: PlayerView(position: PlayerPosition.sideBar),
              ),
          ],
        ),
        if (isFullScreen == true)
          Scaffold(
            backgroundColor: isVideo ? Colors.black : null,
            body: const PlayerView(position: PlayerPosition.fullWindow),
          ),
      ],
    );
  }
}
