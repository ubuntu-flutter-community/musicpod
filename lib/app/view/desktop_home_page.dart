import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
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
    final isVideo = watchPropertyValue((PlayerModel m) => m.isVideo == true);
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

    registerStreamHandler(
      select: (DownloadModel m) => m.messageStream,
      initialValue: null,
      handler: (context, snapshot, cancel) {
        if (snapshot.hasData) {
          showSnackBar(context: context, content: Text(snapshot.data ?? ''));
        }
      },
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
                  if (!playerToTheRight || isMobilePlatform)
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
            color: context.theme.snackBarTheme.backgroundColor != null
                ? contrastColor(context.theme.snackBarTheme.backgroundColor!)
                : null,
          ),
        ],
      ),
    );
  }
}
