import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/persistence/database.dart';
import '../../local_audio/manager/local_audio_manager.dart';
import '../../local_audio/manager/pinned_album_ids_manager.dart';
import '../../local_audio/manager/playlist_ids_manager.dart';
import '../../player/manager/player_manager.dart';
import '../../podcasts/manager/podcast_manager.dart';
import '../../podcasts/manager/subscribed_podcasts_manager.dart';
import '../../radio/manager/radio_manager.dart';
import '../../radio/manager/radio_star_station_manager.dart';
import 'settings_manager.dart';

@Injectable(cache: true)
class WipeManager {
  WipeManager({
    required SettingsManager settingsManager,
    required PodcastManager podcastManager,
    required PinnedAlbumIDsManager pinnedAlbumIDsManager,
    required PlaylistIDsManager playlistIDsManager,
    required SubscribedPodcastsManager subscribedPodcastsManager,
    required RadioStarStationManager radioStarStationManager,
    required RadioManager radioManager,
    required LocalAudioManager localAudioManager,
    required PlayerManager playerManager,
    required Database database,
  }) {
    wipeCommand = Command.createAsyncNoResult((param) async {
      final wipeTypes = param ?? WipeType.values.toSet();

      if (wipeTypes.contains(WipeType.podcasts)) {
        await podcastManager.wipeCommand.runAsync();
        await playerManager.clearAllLastPositions();
        await subscribedPodcastsManager.command.runAsync();
      }

      if (wipeTypes.contains(WipeType.radio)) {
        await radioManager.wipeCommand.runAsync();
        await radioStarStationManager.command.runAsync();
      }

      if (wipeTypes.contains(WipeType.localAudio)) {
        await localAudioManager.initAudiosCommand.runAsync((
          directory: null,
          forceInit: true,
          forceDbOnly: false,
        ));
        await pinnedAlbumIDsManager.command.runAsync();
        await playlistIDsManager.command.runAsync();
      }

      if (wipeTypes.contains(WipeType.player)) {
        await playerManager.resetPlayerState();
      }

      if (wipeTypes.contains(WipeType.settings)) {
        await settingsManager.wipeAllSettingsCommand.runAsync();
      }

      await database.reclaimDiskSpace();
    });
  }

  late final Command<Set<WipeType>?, void> wipeCommand;
}

enum WipeType { podcasts, radio, localAudio, player, settings }
