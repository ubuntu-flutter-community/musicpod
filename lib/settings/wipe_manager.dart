import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/persistence/database.dart';
import '../local_audio/manager/local_audio_manager.dart';
import '../player/player_manager.dart';
import '../podcasts/manager/podcast_manager.dart';
import '../radio/manager/radio_manager.dart';
import 'settings_manager.dart';

@Injectable(cache: true)
class WipeManager {
  WipeManager({
    required SettingsManager settingsManager,
    required PodcastManager podcastManager,
    required RadioManager radioManager,
    required LocalAudioManager localAudioManager,
    required PlayerManager playerManager,
    required Database database,
  }) {
    wipeCommand = Command.createAsyncNoParamNoResult(() async {
      await podcastManager.wipeCommand.runAsync();
      await radioManager.wipeCommand.runAsync();
      await settingsManager.wipeAllSettingsCommand.runAsync();
      await localAudioManager.initAudiosCommand.runAsync((
        directory: null,
        forceInit: true,
        forceDbOnly: false,
      ));
      await playerManager.resetPlayerState();
      await database.reclaimDiskSpace();
    });
  }

  late final Command<void, void> wipeCommand;
}
