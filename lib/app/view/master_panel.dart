import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../common/page_ids.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/ui_constants.dart';
import '../../library/library_model.dart';
import '../../settings/view/settings_action.dart';
import 'create_master_items.dart';
import 'master_tile.dart';
import 'routing_manager.dart';

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

class MasterList extends StatelessWidget {
  const MasterList({super.key});

  @override
  Widget build(BuildContext context) => const CustomScrollView(
    slivers: [
      PermanentPageList(),
      PlaylistList(),
      PodcastList(),
      AlbumsList(),
      StationsList(),
    ],
  );
}

class PermanentPageList extends StatelessWidget with WatchItMixin {
  const PermanentPageList({super.key});

  @override
  Widget build(BuildContext context) {
    final masterItems = permanentMasterItems.whereNot(
      (e) => e.pageId == PageIDs.settings,
    );
    final selectedPageId = watchPropertyValue(
      (RoutingManager m) => m.selectedPageId,
    );
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTileWithPageId(
        item: masterItems.elementAt(index),
        selectedPageId: selectedPageId,
      ),
    );
  }
}

class PlaylistList extends StatelessWidget with WatchItMixin {
  const PlaylistList({super.key});

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LibraryModel m) => m.playlistsLength);
    final masterItems = createPlaylistMasterItems(di<LibraryModel>());
    final selectedPageId = watchPropertyValue(
      (RoutingManager m) => m.selectedPageId,
    );
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTileWithPageId(
        item: masterItems.elementAt(index),
        selectedPageId: selectedPageId,
      ),
    );
  }
}

class PodcastList extends StatelessWidget with WatchItMixin {
  const PodcastList({super.key});

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LibraryModel m) => m.podcastsLength);
    final masterItems = createPodcastMasterItems(context, di<LibraryModel>());
    final selectedPageId = watchPropertyValue(
      (RoutingManager m) => m.selectedPageId,
    );
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTileWithPageId(
        item: masterItems.elementAt(index),
        selectedPageId: selectedPageId,
      ),
    );
  }
}

class StationsList extends StatelessWidget with WatchItMixin {
  const StationsList({super.key});

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LibraryModel m) => m.starredStationsLength);
    final masterItems = createStarredStationsMasterItems(di<LibraryModel>());
    final selectedPageId = watchPropertyValue(
      (RoutingManager m) => m.selectedPageId,
    );
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTileWithPageId(
        item: masterItems.elementAt(index),
        selectedPageId: selectedPageId,
      ),
    );
  }
}

class AlbumsList extends StatelessWidget with WatchItMixin {
  const AlbumsList({super.key});

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LibraryModel m) => m.favoriteAlbumsLength);
    final masterItems = createFavoriteAlbumsMasterItems(di<LibraryModel>());
    final selectedPageId = watchPropertyValue(
      (RoutingManager m) => m.selectedPageId,
    );
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTileWithPageId(
        item: masterItems.elementAt(index),
        selectedPageId: selectedPageId,
      ),
    );
  }
}
