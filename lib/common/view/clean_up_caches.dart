import 'package:flutter_it/flutter_it.dart';

import '../../local_audio/local_cover_manager.dart';
import '../../player/player_manager.dart';
import '../../podcasts/podcast_clean_manager.dart';

void cleanUpUnusedPodcasts({Set<String> deleteMeUrls = const {}}) {
  di<PodcastCleanManager>().command.run((deleteMeUrls: deleteMeUrls));
}

void cleanUpLocalAudioCaches() {
  final playerManager = di<PlayerManager>();
  di<LocalCoverManager>().clear(
    exceptions: playerManager.audio?.albumDbId != null
        ? [playerManager.audio!.albumDbId!]
        : [],
  );
}
