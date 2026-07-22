import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

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

    final playlistIdResults = watchValue(
      (PlaylistIDsManager m) => m.command.results,
    );
    final pinnedAlbumIdResults = watchValue(
      (PinnedAlbumIDsManager m) => m.command.results,
    );
    final starredStationIdResults = watchValue(
      (RadioStarStationManager m) => m.command.results,
    );
    final subscribedPodcastIdResults = watchValue(
      (SubscribedPodcastsManager m) => m.command.results,
    );

    final loadingPlaylists = playlistIdResults.isRunning;
    final loadingAlbums = pinnedAlbumIdResults.isRunning;
    final loadingStations = starredStationIdResults.isRunning;
    final loadingPodcasts = subscribedPodcastIdResults.isRunning;

    final masterItems = getAllMasterItems(
      playlistIDs: playlistIdResults.data ?? [],
      pinnedAlbumIDs: pinnedAlbumIdResults.data ?? [],
      starredStationIDs: starredStationIdResults.data ?? {},
      subscribedPodcastFeedUrls:
          subscribedPodcastIdResults.data?.toList() ?? [],
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
  }
}
