import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
import '../../common/page_ids.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../library/library_model.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../player/player_model.dart';
import '../../player/view/player_view.dart';
import '../../podcasts/download_model.dart';
import '../../podcasts/podcast_model.dart';
import '../../search/search_model.dart';
import '../../podcasts/view/podcast_state_stream_handler.dart';
import '../app_model.dart';
import '../connectivity_model.dart';
import '../../custom_content/view/backup_dialog.dart';
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
              if (di<AppModel>().isBackupScreenNeeded &&
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

  void _onTypeHandler(KeyEvent event) {
    if (!isGtkApp || event.logicalKey == LogicalKeyboardKey.control) {
      return;
    }

    final character = event.character;
    if (event is! KeyDownEvent || character == null || character.isEmpty) {
      return;
    }

    if (FocusManager.instance.primaryFocus?.context?.widget is! FocusScope) {
      return;
    }

    _performSearch(character);
  }

  void _performSearch([String? query]) {
    final libraryModel = di<LibraryModel>();
    final audioType = libraryModel.getCurrentAudioType();
    final searchModel = di<SearchModel>()..setAudioType(audioType);

    if (query != null) {
      searchModel.setSearchQuery(query);
    }

    searchModel.search();
    libraryModel.push(pageId: PageIDs.searchPage);
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

    return KeyboardListener(
      focusNode: di<AppModel>().keyboardListenerFocus,
      onKeyEvent: _onTypeHandler,
      child: CallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
              () => _performSearch
        },
        child: Stack(
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
        ),
      ),
    );
  }
}
