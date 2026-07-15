import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../../common/logging.dart';
import '../../common/persistence/database.dart';
import '../../local_audio/manager/local_audio_manager.dart';
import '../../local_audio/manager/pinned_album_ids_manager.dart';
import '../../local_audio/manager/playlist_ids_manager.dart';
import '../../player/manager/player_manager.dart';
import '../../podcasts/manager/subscribed_podcasts_manager.dart';
import '../../podcasts/service/podcast_service.dart';
import '../../radio/manager/radio_star_station_manager.dart';
import '../../radio/service/radio_service.dart';
import 'settings_manager.dart';

@Injectable(cache: true)
class WipeManager {
  WipeManager({
    required SettingsManager settingsManager,
    required PodcastService podcastService,
    required PinnedAlbumIDsManager pinnedAlbumIDsManager,
    required PlaylistIDsManager playlistIDsManager,
    required SubscribedPodcastsManager subscribedPodcastsManager,
    required RadioStarStationManager radioStarStationManager,
    required RadioService radioService,
    required LocalAudioManager localAudioManager,
    required PlayerManager playerManager,
    required Database database,
  }) {
    Logger.o(tag: '$WipeManager');
    command = Command.createAsyncNoResult((param) async {
      final wipeTypes = param ?? WipeType.values.toSet();

      if (wipeTypes.contains(WipeType.podcasts)) {
        await podcastService.wipeAndBuildPodcastLibrary();
        await playerManager.clearAllLastPositions();
        await subscribedPodcastsManager.command.runAsync();
      }

      if (wipeTypes.contains(WipeType.radio)) {
        await radioService.wipeRadioLibrary();
        await radioStarStationManager.command.runAsync();
      }

      if (wipeTypes.contains(WipeType.localAudio)) {
        await localAudioManager.initAudiosCommand.runAsync((
          directory: null,
          forceInit: true,
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

  late final Command<Set<WipeType>?, void> command;
}

enum WipeType { podcasts, radio, localAudio, player, settings }
