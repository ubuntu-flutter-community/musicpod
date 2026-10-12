import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/persistence/database.dart';
import '../../dependencies.dart';
import '../../local_audio/manager/find_all_album_i_ds_manager.dart';
import '../../local_audio/manager/find_all_artists_manager.dart';
import '../../local_audio/manager/find_all_genres_manager.dart';
import '../../local_audio/manager/find_all_tracks_manager.dart';
import '../../local_audio/manager/has_tracks_manager.dart';
import '../../local_audio/manager/liked_audio_paths_manager.dart';
import '../../local_audio/manager/liked_audios_manager.dart';
import '../../local_audio/manager/local_audio_manager.dart';
import '../../local_audio/manager/pinned_album_ids_manager.dart';
import '../../local_audio/manager/playlist_ids_manager.dart';
import '../../local_audio/manager/tracks_synced_manager.dart';
import '../../local_audio/service/local_audio_service.dart';
import '../../player/manager/audio_progress_manager.dart';
import '../../player/service/player_service.dart';
import '../../podcasts/manager/subscribed_podcasts_manager.dart';
import '../../podcasts/service/podcast_service.dart';
import '../../radio/manager/radio_fav_tag_manager.dart';
import '../../radio/manager/radio_star_station_manager.dart';
import '../../radio/service/radio_service.dart';
import '../service/settings_service.dart';
import 'settings_manager.dart';

part 'wipe_manager.g.dart';

enum WipeType { podcasts, radio, localAudio, player, settings }

@Riverpod(keepAlive: true)
class WipeManager extends _$WipeManager {
  @override
  FutureOr<void> build() {}

  Future<void> wipe([Set<WipeType>? param]) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final wipeTypes = param ?? WipeType.values.toSet();

      if (wipeTypes.contains(WipeType.podcasts)) {
        await di<PodcastService>().wipeAndBuildPodcastLibrary();
        await ref.read(audioProgressManagerProvider.notifier).clearAll();
        ref.invalidate(subscribedPodcastsManagerProvider);
      }

      if (wipeTypes.contains(WipeType.radio)) {
        await di<RadioService>().wipeRadioLibrary();
        ref.invalidate(radioStarStationManagerProvider);
        ref.invalidate(radioFavTagManagerProvider);
      }

      if (wipeTypes.contains(WipeType.localAudio)) {
        await di<LocalAudioService>().init(
          newDirectory: '',
          forceInit: true,
        );
        ref.invalidate(localAudioManagerProvider);
        ref.invalidate(pinnedAlbumIDsManagerProvider);
        ref.invalidate(likedAudiosManagerProvider);
        ref.invalidate(likedAudioPathsManagerProvider);
        ref.invalidate(playlistIDsManagerProvider);
        ref.invalidate(tracksSyncedManagerProvider);
        ref.invalidate(findAllTracksManagerProvider);
        ref.invalidate(findAllAlbumIDsManagerProvider);
        ref.invalidate(findAllArtistsManagerProvider);
        ref.invalidate(findAllGenresManagerProvider);
        ref.invalidate(hasTracksManagerProvider);
      }

      if (wipeTypes.contains(WipeType.player)) {
        await di<PlayerService>().resetPlayerState();
      }

      if (wipeTypes.contains(WipeType.settings)) {
        await di<SettingsService>().wipeAllSettings();
        ref.invalidate(localAudioManagerProvider);
        ref.invalidate(pinnedAlbumIDsManagerProvider);
        ref.invalidate(settingsBoolManagerProvider);
        ref.invalidate(settingsIntManagerProvider);
        ref.invalidate(settingsDoubleManagerProvider);
        ref.invalidate(settingsStringManagerProvider);
        ref.invalidate(settingsStringListManagerProvider);
        ref.invalidate(settingsScrollIndexProvider);
      }

      await di<Database>().reclaimDiskSpace();
    });
  }
}
