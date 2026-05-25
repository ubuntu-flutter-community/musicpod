import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../podcasts/view/recent_downloads_button.dart';
import '../app_config.dart';
import '../page_ids.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/ui_constants.dart';
import '../../podcasts/podcast_manager.dart';
import '../../local_audio/local_audio_manager.dart';
import '../../radio/radio_manager.dart';
import '../../settings/view/settings_action.dart';
import 'create_master_items.dart';
import 'master_tile.dart';
import '../routing_manager.dart';

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
    final playlistIDs = watchValue(
      (LocalAudioManager m) => m.allPlaylistsCommand,
    );
    final masterItems = createPlaylistMasterItems(playlistIDs);
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
    final subs = watchValue((PodcastManager m) => m.togglePodcastCommand);
    final masterItems = createPodcastMasterItems(subs);
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
    final starredStationIDs = watchValue(
      (RadioManager m) => m.toggleStarStationCommand,
    );
    final masterItems = createStarredStationsMasterItems(starredStationIDs);
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
    final pinnedAlbums = watchValue(
      (LocalAudioManager m) => m.togglePinnedAlbumCommand,
    );
    final masterItems = createPinnedAlbumsMasterItems(pinnedAlbums);
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
