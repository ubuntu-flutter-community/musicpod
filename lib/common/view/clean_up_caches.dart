import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../podcasts/manager/podcast_clean_manager.dart';

void cleanUpUnusedPodcasts() => di<PodcastCleanManager>().command.run();

/// Evicts all decoded textures from Flutter's in-memory image cache,
/// freeing RAM without touching cached image files on disk.
void clearInMemoryImageCache() {
  PaintingBinding.instance.imageCache
    ..clear()
    ..clearLiveImages();
}

/// Empties the on-disk cache used by CachedNetworkImage.
Future<void> clearDiskImageCache() =>
    CachedNetworkImageProvider.defaultCacheManager.emptyCache();

/// Evicts the in-memory image cache and empties the on-disk cache.
Future<void> clearNetworkImageCache() async {
  clearInMemoryImageCache();
  await clearDiskImageCache();
}
