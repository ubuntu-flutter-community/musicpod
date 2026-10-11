import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/progress.dart';
import '../../local_audio/manager/pinned_album_ids_manager.dart';
import '../../local_audio/manager/playlist_ids_manager.dart';
import '../../podcasts/manager/subscribed_podcasts_manager.dart';
import '../../radio/manager/radio_star_station_manager.dart';
import '../routing_manager.dart';
import 'create_master_items.dart';

class MasterItemPage extends StatelessWidget with WatchItMixin {
  const MasterItemPage({super.key, required this.pageId});

  final String pageId;

  @override
  Widget build(BuildContext context) {
    final routingManagerInitializing = watchValue(
      (RoutingManager m) => m.selectedPageIdCommand.isRunning,
    );

    return Consumer(
      builder: (context, ref, _) {
        final playlistIdAsync = ref.watch(playlistIDsManagerProvider);
        final pinnedAlbumIdAsync = ref.watch(pinnedAlbumIDsManagerProvider);
        final starredStationIdAsync = ref.watch(radioStarStationManagerProvider);
        final subscribedPodcastsAsync =
            ref.watch(subscribedPodcastsManagerProvider);

        final loadingPlaylists = playlistIdAsync.isLoading;
        final loadingAlbums = pinnedAlbumIdAsync.isLoading;
        final loadingStations = starredStationIdAsync.isLoading;
        final loadingPodcasts = subscribedPodcastsAsync.isLoading;

        final masterItems = getAllMasterItems(
          playlistIDs: playlistIdAsync.value ?? [],
          pinnedAlbumIDs: pinnedAlbumIdAsync.value ?? [],
          starredStationIDs: starredStationIdAsync.value ?? {},
          subscribedPodcastFeedUrls:
              subscribedPodcastsAsync.value?.toList() ?? [],
        );
        final item = masterItems.firstWhereOrNull((e) => e.pageId == pageId);
        if (item != null && !routingManagerInitializing)
          return item.pageBuilder(context);

        if (routingManagerInitializing ||
            loadingPlaylists ||
            loadingAlbums ||
            loadingStations ||
            loadingPodcasts) {
          return const Scaffold(body: Center(child: Progress()));
        }

        return masterItems.first.pageBuilder(context);
      },
    );
  }
}
