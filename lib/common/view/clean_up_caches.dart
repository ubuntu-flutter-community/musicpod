import 'package:flutter_it/flutter_it.dart';

import '../../player/player_manager.dart';
import '../../podcasts/podcast_clean_manager.dart';
import '../../local_audio/local_audio_manager.dart';
import '../../local_audio/local_cover_manager.dart';

void cleanUpUnusedPodcasts() {
  di<PodcastCleanManager>().command.run();
}

void cleanUpLocalAudioCaches() {
  final playerManager = di<PlayerManager>();
  di<LocalCoverManager>().clear(
    exceptions: playerManager.audio?.albumDbId != null
        ? [playerManager.audio!.albumDbId!]
        : [],
  );
  di<LocalAudioManager>().clear();
}
