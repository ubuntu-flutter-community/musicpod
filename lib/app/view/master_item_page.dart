import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/progress.dart';
import '../../local_audio/pinned_album_i_ds_manager.dart';
import '../../local_audio/playlist_ids_manager.dart';
import '../../podcasts/podcast_manager.dart';
import '../../radio/radio_manager.dart';
import 'create_master_items.dart';

class MasterItemPage extends StatelessWidget with WatchItMixin {
  const MasterItemPage({super.key, required this.pageId});

  final String pageId;

  @override
  Widget build(BuildContext context) {
    final playlistIdResults = watchValue(
      (PlaylistIDsManager m) => m.command.results,
    );
    final pinnedAlbumIdResults = watchValue(
      (PinnedAlbumIDsManager m) => m.command.results,
    );
    final starredStationIdResults = watchValue(
      (RadioManager m) => m.toggleStarStationCommand.results,
    );
    final subscribedPodcastIdResults = watchValue(
      (PodcastManager m) => m.togglePodcastCommand.results,
    );

    final loadingPlaylists = playlistIdResults.isRunning;
    final loadingAlbums = pinnedAlbumIdResults.isRunning;
    final loadingStations = starredStationIdResults.isRunning;
    final loadingPodcasts = subscribedPodcastIdResults.isRunning;

    final masterItems = getAllMasterItems(
      playlistIDs: playlistIdResults.data ?? [],
      pinnedAlbumIDs: pinnedAlbumIdResults.data ?? [],
      starredStationIDs: starredStationIdResults.data ?? [],
      subscribedPodcastFeedUrls:
          subscribedPodcastIdResults.data?.toList() ?? [],
    );
    final item = masterItems.firstWhereOrNull((e) => e.pageId == pageId);
    if (item != null) return item.pageBuilder(context);

    if (loadingPlaylists ||
        loadingAlbums ||
        loadingStations ||
        loadingPodcasts) {
      return const Scaffold(body: Center(child: Progress()));
    }

    return masterItems.first.pageBuilder(context);
  }
}
