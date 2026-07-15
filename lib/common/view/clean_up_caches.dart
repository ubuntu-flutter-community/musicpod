import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../podcasts/manager/podcast_clean_manager.dart';

void cleanUpUnusedPodcasts() => di<PodcastCleanManager>().command.run();

Future<void> clearNetworkImageCache() async {
  // Evict the in-memory image cache.
  PaintingBinding.instance.imageCache
    ..clear()
    ..clearLiveImages();
  // Empty the on-disk cache used by CachedNetworkImage.
  await CachedNetworkImageProvider.defaultCacheManager.emptyCache();
}
