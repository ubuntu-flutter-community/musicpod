import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/header_bar.dart';
import '../../common/view/ui_constants.dart';
import '../../local_audio/manager/pinned_album_ids_manager.dart';
import '../../local_audio/manager/playlist_ids_manager.dart';
import '../../podcasts/manager/subscribed_podcasts_manager.dart';
import '../../podcasts/view/recent_downloads_button.dart';
import '../../radio/manager/radio_star_station_manager.dart';
import '../../settings/view/settings_action.dart';
import '../app_config.dart';
import '../page_ids.dart';
import '../routing_manager.dart';
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
          actions: [
            Padding(
              padding: EdgeInsets.only(right: kSmallestSpace),
              child: const RecentDownloadsButton(),
            ),
          ],
          includeBackButton: false,
          includeSidebarButton: false,
          backgroundColor: Colors.transparent,
          style: YaruTitleBarStyle.undecorated,
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
    final selectedPageId = watchValue(
      (RoutingManager m) => m.selectedPageIdCommand,
    );
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTile(
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
    final playlistIDs = watchValue((PlaylistIDsManager m) => m.command);
    final masterItems = createPlaylistMasterItems(playlistIDs);
    final selectedPageId = watchValue(
      (RoutingManager m) => m.selectedPageIdCommand,
    );
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTile(
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
    final subs = watchValue((SubscribedPodcastsManager m) => m.command);
    final masterItems = createPodcastMasterItems(subs.toList());
    final selectedPageId = watchValue(
      (RoutingManager m) => m.selectedPageIdCommand,
    );
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTile(
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
    final starredStationIDs = watchValue(
      (RadioStarStationManager m) => m.command,
    );
    final masterItems = createStarredStationsMasterItems(starredStationIDs);
    final selectedPageId = watchValue(
      (RoutingManager m) => m.selectedPageIdCommand,
    );
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTile(
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
    final pinnedAlbums = watchValue((PinnedAlbumIDsManager m) => m.command);
    final masterItems = createPinnedAlbumsMasterItems(pinnedAlbums);
    final selectedPageId = watchValue(
      (RoutingManager m) => m.selectedPageIdCommand,
    );
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTile(
        item: masterItems.elementAt(index),
        selectedPageId: selectedPageId,
      ),
    );
  }
}
