import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../patch_notes/patch_notes_dialog.dart';
import '../../player/view/player_view.dart';
import '../../settings/settings_model.dart';
import '../app_model.dart';
import '../connectivity_model.dart';
import 'master_detail_page.dart';

class MusicPodScaffold extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MusicPodScaffold({super.key});

  @override
  State<MusicPodScaffold> createState() => _MusicPodScaffoldState();
}

class _MusicPodScaffoldState extends State<MusicPodScaffold> {
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
          builder: (_) => const PatchNotesDialog(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerToTheRight = context.mediaQuerySize.width > kSideBarThreshHold;
    final isFullScreen = watchPropertyValue((AppModel m) => m.fullWindowMode);
    final enableDiscordRPC =
        watchPropertyValue((SettingsModel m) => m.enableDiscordRPC);

    if (allowDiscordRPC && enableDiscordRPC) {
      registerStreamHandler(
        select: (AppModel m) => m.isDiscordConnectedStream,
        handler: (context, snapshot, cancel) {
          if (snapshot.data == true) {
            showSnackBar(
              context: context,
              duration: const Duration(seconds: 3),
              content: _DiscordConnectContent(connected: snapshot.data == true),
            );
          }
        },
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Expanded(child: MasterDetailPage()),
                  if (!playerToTheRight || isMobile)
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
          const Scaffold(
            body: PlayerView(position: PlayerPosition.fullWindow),
          ),
      ],
    );
  }
}

class _DiscordConnectContent extends StatelessWidget {
  const _DiscordConnectContent({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: space(
        widthGap: 10,
        children: [
          Text(
            '${connected ? l10n.connectedTo : l10n.disconnectedFrom}'
            ' ${l10n.exposeToDiscordTitle}',
          ),
          Icon(
            TablerIcons.brand_discord_filled,
            color: context.theme.primaryColor,
          ),
        ],
      ),
    );
  }
}
