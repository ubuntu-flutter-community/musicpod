import 'package:flutter_it/flutter_it.dart';

import '../player/player_manager.dart';
import 'local_audio_manager.dart';
import 'local_cover_manager.dart';

mixin LocalAudioClearHandler on WatchItMixin {
  void clearLocalAudioCaches() {
    callOnceAfterThisBuild((_) {
      di<LocalCoverManager>().clear(
        exceptions: di<PlayerManager>().audio?.albumDbId != null
            ? [di<PlayerManager>().audio!.albumDbId!]
            : [],
      );
      di<LocalAudioManager>().clear();
    });
  }
}
