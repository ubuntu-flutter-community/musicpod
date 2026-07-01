import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../local_audio/manager/local_cover_manager.dart';
import '../../player/manager/player_manager.dart';
import '../../podcasts/manager/podcast_clean_manager.dart';

void cleanUpUnusedPodcasts() => di<PodcastCleanManager>().command.run();

void clearLocalCovers() {
  final playerManager = di<PlayerManager>();
  di<LocalCoverManager>().clear(
    exceptions: playerManager.audio?.albumDbId != null
        ? [playerManager.audio!.albumDbId!]
        : [],
  );
}

Future<void> clearNetworkImageCache() async {
  // Evict the in-memory image cache.
  PaintingBinding.instance.imageCache
    ..clear()
    ..clearLiveImages();
  // Empty the on-disk cache used by CachedNetworkImage.
  await CachedNetworkImageProvider.defaultCacheManager.emptyCache();
}
