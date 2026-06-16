import 'package:flutter_it/flutter_it.dart';

import '../player/player_manager.dart';
import 'local_audio_manager.dart';
import 'local_cover_manager.dart';

mixin LocalAudioClearHandler on WatchItMixin {
  void clearLocalAudioCaches() {
    callOnceAfterThisBuild((_) {
      final playerManager = di<PlayerManager>();
      di<LocalCoverManager>().clear(
        exceptions: playerManager.audio?.albumDbId != null
            ? [playerManager.audio!.albumDbId!]
            : [],
      );
      di<LocalAudioManager>().clear();
    });
  }
}
