import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    key: PageStorageKey('master_panel_scroll'),
    slivers: [
      PermanentPageList(),
      PlaylistList(),
      PodcastList(),
      AlbumsList(),
      StationsList(),
    ],
  );
}

class PermanentPageList extends ConsumerWidget {
  const PermanentPageList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masterItems = permanentMasterItems.whereNot(
      (e) => e.pageId == PageIDs.settings,
    );
    final selectedPageId = ref.watch(routingManagerProvider);
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTile(
        item: masterItems.elementAt(index),
        selectedPageId: selectedPageId,
      ),
    );
  }
}

class PlaylistList extends ConsumerWidget {
  const PlaylistList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPageId = ref.watch(routingManagerProvider);
    final playlistIDs = ref.watch(playlistIDsManagerProvider).value ?? [];
    final masterItems = createPlaylistMasterItems(playlistIDs);
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTile(
        item: masterItems.elementAt(index),
        selectedPageId: selectedPageId,
      ),
    );
  }
}

class PodcastList extends ConsumerWidget {
  const PodcastList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPageId = ref.watch(routingManagerProvider);
    final subs =
        ref.watch(subscribedPodcastsManagerProvider).value ?? <String>{};
    final masterItems = createPodcastMasterItems(subs.toList());
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTile(
        item: masterItems.elementAt(index),
        selectedPageId: selectedPageId,
      ),
    );
  }
}

class StationsList extends ConsumerWidget {
  const StationsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPageId = ref.watch(routingManagerProvider);
    final starredStationIDs =
        ref.watch(radioStarStationManagerProvider).value ?? {};
    final masterItems = createStarredStationsMasterItems(starredStationIDs);
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTile(
        item: masterItems.elementAt(index),
        selectedPageId: selectedPageId,
      ),
    );
  }
}

class AlbumsList extends ConsumerWidget {
  const AlbumsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPageId = ref.watch(routingManagerProvider);
    final pinnedAlbums = ref.watch(pinnedAlbumIDsManagerProvider).value ?? [];
    final masterItems = createPinnedAlbumsMasterItems(pinnedAlbums);
    return SliverList.builder(
      itemCount: masterItems.length,
      itemBuilder: (context, index) => MasterTile(
        item: masterItems.elementAt(index),
        selectedPageId: selectedPageId,
      ),
    );
  }
}
