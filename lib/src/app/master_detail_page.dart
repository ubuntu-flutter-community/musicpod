import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../data.dart';
import '../../library.dart';
import '../../settings.dart';
import '../common/colors.dart';
import '../common/common_widgets.dart';
import '../globals.dart';
import '../l10n/l10n.dart';
import 'master_item.dart';

class MasterDetailPage extends StatelessWidget {
  const MasterDetailPage({
    super.key,
    required this.setIndex,
    required this.onDirectorySelected,
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
  final Future<void> Function(String?) onDirectorySelected;

  @override
  Widget build(BuildContext context) {
    return YaruMasterDetailTheme(
      data: YaruMasterDetailTheme.of(context).copyWith(
        sideBarColor: getSideBarColor(Theme.of(context)),
      ),
      child: YaruMasterDetailPage(
        navigatorKey: navigatorKey,
        onSelected: (value) => setIndex(value ?? 0),
        appBar: HeaderBar(
          style: YaruTitleBarStyle.undecorated,
          title: const Text('MusicPod'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SettingsTile(onDirectorySelected: onDirectorySelected),
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
          if (index == 3 || index == 6) {
            return masterItems[index].titleBuilder(context);
          } else if (index == 4) {
            return YaruMasterTile(
              selected: false,
              title: masterItems[index].titleBuilder(context),
              leading: masterItems[index].iconBuilder?.call(context, false),
              onTap: () => showDialog(
                context: context,
                builder: (context) {
                  return PlaylistDialog(
                    playlistName: context.l10n.createNewPlaylist,
                    onCreateNewPlaylist: addPlaylist,
                  );
                },
              ),
            );
          }
          return Padding(
            padding:
                index == 0 ? const EdgeInsets.only(top: 5) : EdgeInsets.zero,
            child: YaruMasterTile(
              title: masterItems[index].titleBuilder(context),
              leading: masterItems[index].iconBuilder == null
                  ? null
                  : masterItems[index].iconBuilder!(
                      context,
                      selected,
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
