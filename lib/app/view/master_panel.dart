import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/ui_constants.dart';
import '../../library/library_model.dart';
import '../../settings/view/settings_action.dart';
import 'create_master_items.dart';
import 'master_tile.dart';

class MasterPanel extends StatelessWidget {
  const MasterPanel({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: kMasterDetailSideBarWidth,
        child: Column(
          children: [
            HeaderBar(
              includeBackButton: false,
              includeSidebarButton: false,
              backgroundColor: Colors.transparent,
              style: YaruTitleBarStyle.undecorated,
              adaptive: false,
              title: Text(AppConfig.appTitle),
            ),
            Expanded(child: MasterList()),
            SettingsButton.tile(),
          ],
        ),
      );
}

class MasterList extends StatelessWidget with WatchItMixin {
  const MasterList({super.key});

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LibraryModel m) => m.playlistsLength);
    watchPropertyValue((LibraryModel m) => m.starredStationsLength);
    watchPropertyValue((LibraryModel m) => m.favoriteAlbumsLength);
    watchPropertyValue((LibraryModel m) => m.podcastsLength);
    final selectedPageId =
        watchPropertyValue((LibraryModel m) => m.selectedPageId);
    final masterItems = createMasterItems();
    final libraryModel = di<LibraryModel>();
    return ListView.separated(
      itemCount: masterItems.length,
      itemBuilder: (context, index) {
        final item = masterItems.elementAt(index);
        return MasterTile(
          key: ValueKey(item.pageId),
          onTap: () => libraryModel.push(pageId: item.pageId),
          pageId: item.pageId,
          leading: item.iconBuilder?.call(selectedPageId == item.pageId),
          title: item.titleBuilder(context),
          subtitle: item.subtitleBuilder?.call(context),
          selected: selectedPageId == item.pageId,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(
        height: 5,
      ),
    );
  }
}
