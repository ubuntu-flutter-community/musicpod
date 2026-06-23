import 'package:flutter/rendering.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../local_audio/manager/local_cover_manager.dart';
import '../../player/player_manager.dart';
import '../../podcasts/manager/podcast_clean_manager.dart';

void cleanUpUnusedPodcasts({Set<String> deleteMeUrls = const {}}) {
  di<PodcastCleanManager>().command.run((deleteMeUrls: deleteMeUrls));
}

void clearLocalCovers() {
  final playerManager = di<PlayerManager>();
  di<LocalCoverManager>().clear(
    exceptions: playerManager.audio?.albumDbId != null
        ? [playerManager.audio!.albumDbId!]
        : [],
  );
}

void clearImageCache() {
  PaintingBinding.instance.imageCache.clear();

  PaintingBinding.instance.imageCache.clearLiveImages();
}
