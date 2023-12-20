import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../data.dart';
import '../../library.dart';
import '../../player.dart';
import '../../radio.dart';
import '../../settings.dart';
import '../../theme.dart';
import '../common/common_widgets.dart';
import '../globals.dart';
import '../l10n/l10n.dart';
import 'master_item.dart';

class MasterDetailPage extends StatelessWidget {
  const MasterDetailPage({
    super.key,
    required this.setIndex,
    required this.totalListAmount,
    required this.index,
    required this.masterItems,
    required this.addPlaylist,
  });

  final void Function(int? value) setIndex;
  final int totalListAmount;
  final int? index;
  final List<MasterItem> masterItems;
  final void Function(String name, Set<Audio> audios) addPlaylist;

  @override
  Widget build(BuildContext context) {
    final startPlaylist = context.read<PlayerModel>().startPlaylist;

    return YaruMasterDetailTheme(
      data: YaruMasterDetailTheme.of(context).copyWith(
        sideBarColor: getSideBarColor(context.t),
      ),
      child: YaruMasterDetailPage(
        navigatorKey: navigatorKey,
        onSelected: (value) => setIndex(value ?? 0),
        appBar: const HeaderBar(
          style: YaruTitleBarStyle.undecorated,
          title: Text('MusicPod'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: SettingsTile(),
            ),
          ],
        ),
        layoutDelegate: const YaruMasterFixedPaneDelegate(
          paneWidth: 250,
        ),
        breakpoint: 720,
        controller: YaruPageController(
          length: totalListAmount,
          initialIndex: index ?? 0,
        ),
        tileBuilder: (context, index, selected, availableWidth) {
          final item = masterItems[index];
          if (index == 3 || index == 6) {
            return item.titleBuilder(context);
          }
          return Padding(
            padding:
                index == 0 ? const EdgeInsets.only(top: 5) : EdgeInsets.zero,
            child: MasterTile(
              selected: index == 4 ? false : selected,
              title: item.titleBuilder(context),
              subtitle: item.subtitleBuilder?.call(context),
              onPlay: item.content?.$1 == null || item.content?.$2 == null
                  ? null
                  : () => startPlaylist(
                        item.content!.$2,
                        item.content!.$1,
                      ),
              leading: item.iconBuilder == null
                  ? null
                  : Padding(
                      padding: index <= 3
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(right: 4),
                      child: item.iconBuilder!(
                        context,
                        selected,
                      ),
                    ),
              onTap: index != 4
                  ? null
                  : () => showDialog(
                        context: context,
                        builder: (context) {
                          return PlaylistDialog(
                            playlistName: context.l10n.createNewPlaylist,
                            onCreateNewPlaylist: addPlaylist,
                          );
                        },
                      ),
            ),
          );
        },
        pageBuilder: (context, index) => YaruDetailPage(
          body: masterItems[index].pageBuilder(context),
        ),
      ),
    );
  }
}
