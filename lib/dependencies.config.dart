// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:github/github.dart' as _i535;
import 'package:injectable/injectable.dart' as _i526;
import 'package:local_notifier/local_notifier.dart' as _i526;
import 'package:media_kit_video/media_kit_video.dart' as _i150;
import 'package:package_info_plus/package_info_plus.dart' as _i655;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:window_manager/window_manager.dart' as _i740;

import 'app/app_manager.dart' as _i369;
import 'app/routing_manager.dart' as _i971;
import 'app/sidebar_audios_manager.dart' as _i190;
import 'app/window_size_to_settings_listener.dart' as _i517;
import 'common/data/audio.dart' as _i537;
import 'common/data/retry_capsule.dart' as _i327;
import 'common/persistence/database.dart' as _i115;
import 'common/retry_manager.dart' as _i569;
import 'custom_content/custom_content_manager.dart' as _i1028;
import 'expose/expose_manager.dart' as _i987;
import 'expose/expose_service.dart' as _i820;
import 'expose/lastfm_service.dart' as _i820;
import 'expose/listenbrainz_service.dart' as _i348;
import 'external_path/external_path_service.dart' as _i551;
import 'local_audio/album_ids_of_artist_manager.dart' as _i234;
import 'local_audio/album_ids_of_genre_manager.dart' as _i75;
import 'local_audio/change_local_meta_data_manager.dart' as _i46;
import 'local_audio/find_album_manager.dart' as _i160;
import 'local_audio/find_album_name_manager.dart' as _i548;
import 'local_audio/find_all_album_i_ds_manager.dart' as _i1054;
import 'local_audio/find_all_artists_manager.dart' as _i142;
import 'local_audio/find_all_genres_manager.dart' as _i486;
import 'local_audio/find_all_tracks_manager.dart' as _i897;
import 'local_audio/find_artist_of_album_manager.dart' as _i234;
import 'local_audio/find_playlist_manager.dart' as _i305;
import 'local_audio/liked_audios_manager.dart' as _i215;
import 'local_audio/local_audio_manager.dart' as _i688;
import 'local_audio/local_audio_service.dart' as _i438;
import 'local_audio/local_cover_manager.dart' as _i439;
import 'local_audio/local_cover_service.dart' as _i57;
import 'local_audio/persistence/local_audio_dao.dart' as _i688;
import 'local_audio/pinned_album_i_ds_manager.dart' as _i942;
import 'local_audio/playlist_ids_manager.dart' as _i803;
import 'lyrics/lyrics_manager.dart' as _i23;
import 'lyrics/lyrics_service.dart' as _i546;
import 'notifications/notifications_service.dart' as _i57;
import 'player/mpv_metadata_manager.dart' as _i112;
import 'player/persistence/player_dao.dart' as _i443;
import 'player/player_manager.dart' as _i444;
import 'player/player_service.dart' as _i38;
import 'podcasts/download_manager.dart' as _i388;
import 'podcasts/download_service.dart' as _i616;
import 'podcasts/episodes_manager.dart' as _i0;
import 'podcasts/persistence/podcast_dao.dart' as _i597;
import 'podcasts/podcast_clean_manager.dart' as _i425;
import 'podcasts/podcast_genre_manager.dart' as _i973;
import 'podcasts/podcast_manager.dart' as _i351;
import 'podcasts/podcast_service.dart' as _i721;
import 'radio/online_art_manager.dart' as _i635;
import 'radio/online_art_service.dart' as _i328;
import 'radio/persistence/radio_dao.dart' as _i414;
import 'radio/radio_manager.dart' as _i749;
import 'radio/radio_service.dart' as _i811;
import 'radio/station_manager.dart' as _i752;
import 'search/search_manager.dart' as _i807;
import 'settings/settings_manager.dart' as _i651;
import 'settings/settings_service.dart' as _i763;
import 'settings/view/licenses_dialog.dart' as _i1009;
import 'third_party/audio_service_module.dart' as _i739;
import 'third_party/database_module.dart' as _i440;
import 'third_party/dio_module.dart' as _i1039;
import 'third_party/github_module.dart' as _i207;
import 'third_party/local_notifier_module.dart' as _i8;
import 'third_party/media_kit_module.dart' as _i94;
import 'third_party/package_info_module.dart' as _i855;
import 'third_party/shared_preferences_module.dart' as _i357;
import 'third_party/window_manager_module.dart' as _i271;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    final githubModule = _$GithubModule();
    final localNotifierModule = _$LocalNotifierModule();
    final mediaKitModule = _$MediaKitModule();
    final packageInfoModule = _$PackageInfoModule();
    final sharedPreferencesModule = _$SharedPreferencesModule();
    final windowManagerModule = _$WindowManagerModule();
    final databaseModule = _$DatabaseModule();
    final audioServiceModule = _$AudioServiceModule();
    gh.factory<_i361.Dio>(() => dioModule.create());
    gh.factory<_i535.GitHub>(() => githubModule.gitHub);
    await gh.factoryAsync<_i526.LocalNotifier>(
      () => localNotifierModule.create,
      preResolve: true,
    );
    gh.factory<_i150.VideoController>(() => mediaKitModule.mediaKit);
    await gh.factoryAsync<_i655.PackageInfo>(
      () => packageInfoModule.packageInfo,
      preResolve: true,
    );
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.sharedPreferences,
      preResolve: true,
    );
    await gh.factoryAsync<_i740.WindowManager>(
      () => windowManagerModule.create(),
      preResolve: true,
    );
    gh.lazySingleton<_i551.ExternalPathService>(
      () => const _i551.ExternalPathService(),
    );
    gh.lazySingleton<_i546.LocalLyricsService>(
      () => _i546.LocalLyricsService(),
    );
    gh.lazySingleton<_i1009.LicenseStore>(() => _i1009.LicenseStore());
    gh.lazySingleton<_i115.Database>(() => databaseModule.database);
    gh.lazySingleton<_i328.OnlineArtService>(
      () => _i328.OnlineArtService(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i443.PlayerDao>(
      () => _i443.PlayerDao(db: gh<_i115.Database>()),
    );
    gh.lazySingleton<_i597.PodcastDao>(
      () => _i597.PodcastDao(db: gh<_i115.Database>()),
    );
    gh.lazySingleton<_i414.RadioDao>(
      () => _i414.RadioDao(db: gh<_i115.Database>()),
    );
    gh.lazySingleton<_i635.OnlineArtManager>(
      () => _i635.OnlineArtManager(
        onlineArtService: gh<_i328.OnlineArtService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.singleton<_i811.RadioService>(
      () => _i811.RadioService(dao: gh<_i414.RadioDao>()),
    );
    gh.lazySingleton<_i688.LocalAudioDao>(
      () => _i688.LocalAudioDao(database: gh<_i115.Database>()),
    );
    gh.factoryParam<_i752.StationManager, String, dynamic>(
      (uuid, _) => _i752.StationManager.create(
        uuid: uuid,
        radioService: gh<_i811.RadioService>(),
      ),
    );
    gh.lazySingleton<_i763.SettingsService>(
      () => _i763.SettingsService(
        sharedPreferences: gh<_i460.SharedPreferences>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i57.NotificationsService>(
      () => _i57.NotificationsService(localNotifier: gh<_i526.LocalNotifier>()),
    );
    gh.lazySingleton<_i57.LocalCoverService>(
      () => _i57.LocalCoverService(dao: gh<_i688.LocalAudioDao>()),
    );
    gh.factoryParam<_i569.RetryManager, _i327.RetryCapsule, dynamic>(
      (retryCapsule, _) =>
          _i569.RetryManager.create(retryCapsule: retryCapsule),
    );
    gh.lazySingleton<_i616.DownloadService>(
      () => _i616.DownloadService(
        externalPathService: gh<_i551.ExternalPathService>(),
        settingsService: gh<_i763.SettingsService>(),
        dio: gh<_i361.Dio>(),
      ),
    );
    gh.lazySingleton<_i546.OnlineLyricsService>(
      () => _i546.OnlineLyricsService(
        dio: gh<_i361.Dio>(),
        localAudioDao: gh<_i688.LocalAudioDao>(),
      ),
    );
    gh.singleton<_i749.RadioManager>(
      () => _i749.RadioManager(radioService: gh<_i811.RadioService>()),
    );
    gh.lazySingleton<_i820.LastfmService>(
      () => _i820.LastfmService(settingsService: gh<_i763.SettingsService>()),
    );
    gh.lazySingleton<_i348.ListenBrainzService>(
      () => _i348.ListenBrainzService(
        settingsService: gh<_i763.SettingsService>(),
      ),
    );
    gh.factoryCached<_i23.LyricsManager>(
      () => _i23.LyricsManager(
        localLyricsService: gh<_i546.LocalLyricsService>(),
        onlineLyricsService: gh<_i546.OnlineLyricsService>(),
      ),
    );
    gh.lazySingleton<_i721.PodcastService>(
      () => _i721.PodcastService(
        settingsService: gh<_i763.SettingsService>(),
        dao: gh<_i597.PodcastDao>(),
      ),
    );
    gh.lazySingleton<_i820.ExposeService>(
      () => _i820.ExposeService(
        lastFmService: gh<_i820.LastfmService>(),
        listenBrainzService: gh<_i348.ListenBrainzService>(),
      ),
    );
    await gh.singletonAsync<_i38.PlayerService>(
      () {
        final i = _i38.PlayerService(
          controller: gh<_i150.VideoController>(),
          exposeService: gh<_i820.ExposeService>(),
          localCoverService: gh<_i57.LocalCoverService>(),
          podcastService: gh<_i721.PodcastService>(),
          dao: gh<_i443.PlayerDao>(),
        );
        return i.init().then((_) => i);
      },
      preResolve: true,
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i444.PlayerManager>(
      () => _i444.PlayerManager(service: gh<_i38.PlayerService>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i987.ExposeManager>(
      () => _i987.ExposeManager(exposeService: gh<_i820.ExposeService>()),
    );
    gh.lazySingleton<_i438.LocalAudioService>(
      () => _i438.LocalAudioService(
        localCoverService: gh<_i57.LocalCoverService>(),
        settingsService: gh<_i763.SettingsService>(),
        localAudioDao: gh<_i688.LocalAudioDao>(),
      ),
    );
    gh.factoryParam<_i0.EpisodesManager, String, dynamic>(
      (feedUrl, _) => _i0.EpisodesManager.create(
        feedUrl: feedUrl,
        podcastService: gh<_i721.PodcastService>(),
      ),
    );
    gh.factoryCachedParam<_i973.PodcastGenreManager, String, dynamic>(
      (feedUrl, _) => _i973.PodcastGenreManager(
        feedUrl: feedUrl,
        podcastService: gh<_i721.PodcastService>(),
      ),
    );
    gh.factoryCached<_i439.LocalCoverManager>(
      () => _i439.LocalCoverManager(
        localCoverService: gh<_i57.LocalCoverService>(),
      ),
    );
    gh.lazySingleton<_i369.AppManager>(
      () => _i369.AppManager(
        packageInfo: gh<_i655.PackageInfo>(),
        settingsService: gh<_i763.SettingsService>(),
        gitHub: gh<_i535.GitHub>(),
        localAudioService: gh<_i438.LocalAudioService>(),
      ),
    );
    gh.factoryCachedParam<_i75.AlbumIDsOfGenreManager, String, dynamic>(
      (genre, _) => _i75.AlbumIDsOfGenreManager(
        genre: genre,
        service: gh<_i438.LocalAudioService>(),
      ),
    );
    gh.factoryCachedParam<
      _i46.ChangeLocalMetaDataManager,
      _i537.Audio,
      dynamic
    >(
      (audio, _) => _i46.ChangeLocalMetaDataManager(
        audio: audio,
        localAudioService: gh<_i438.LocalAudioService>(),
      ),
    );
    gh.lazySingleton<_i388.DownloadManager>(
      () => _i388.DownloadManager(
        podcastService: gh<_i721.PodcastService>(),
        downloadService: gh<_i616.DownloadService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factoryCached<_i1054.FindAllAlbumIDsManager>(
      () => _i1054.FindAllAlbumIDsManager(gh<_i438.LocalAudioService>()),
    );
    gh.factoryCached<_i142.FindAllArtistsManager>(
      () => _i142.FindAllArtistsManager(gh<_i438.LocalAudioService>()),
    );
    gh.factoryCached<_i486.FindAllGenresManager>(
      () => _i486.FindAllGenresManager(gh<_i438.LocalAudioService>()),
    );
    gh.factoryCached<_i215.LikedAudiosManager>(
      () => _i215.LikedAudiosManager(gh<_i438.LocalAudioService>()),
    );
    gh.lazySingleton<_i651.SettingsManager>(
      () => _i651.SettingsManager(
        service: gh<_i763.SettingsService>(),
        podcastService: gh<_i721.PodcastService>(),
        localAudioService: gh<_i438.LocalAudioService>(),
        radioService: gh<_i811.RadioService>(),
        playerService: gh<_i38.PlayerService>(),
      ),
    );
    gh.singleton<_i351.PodcastManager>(
      () => _i351.PodcastManager(podcastService: gh<_i721.PodcastService>()),
    );
    gh.factoryCached<_i425.PodcastCleanManager>(
      () => _i425.PodcastCleanManager(gh<_i721.PodcastService>()),
    );
    await gh.singletonAsync<_i517.WindowSizeToSettingsListener>(() {
      final i = _i517.WindowSizeToSettingsListener(
        sharedPreferences: gh<_i460.SharedPreferences>(),
        playerService: gh<_i38.PlayerService>(),
        windowManager: gh<_i740.WindowManager>(),
      );
      return i.init().then((_) => i);
    }, preResolve: true);
    gh.lazySingleton<_i971.RoutingManager>(
      () => _i971.RoutingManager(
        podcastService: gh<_i721.PodcastService>(),
        localAudioService: gh<_i438.LocalAudioService>(),
        radioService: gh<_i811.RadioService>(),
        settingsService: gh<_i763.SettingsService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    await gh.factoryAsync<_i739.AudioServiceHandler>(
      () => audioServiceModule.audioServiceHandler(
        gh<_i38.PlayerService>(),
        gh<_i740.WindowManager>(),
      ),
      preResolve: true,
    );
    await gh.singletonAsync<_i112.MpvMetadataManager>(
      () {
        final i = _i112.MpvMetadataManager(
          playerService: gh<_i38.PlayerService>(),
          onlineArtService: gh<_i328.OnlineArtService>(),
          exposeService: gh<_i820.ExposeService>(),
          settingsService: gh<_i763.SettingsService>(),
          lyricsManager: gh<_i23.LyricsManager>(),
        );
        return i.init().then((_) => i);
      },
      preResolve: true,
      dispose: (i) => i.dispose(),
    );
    gh.singleton<_i688.LocalAudioManager>(
      () => _i688.LocalAudioManager(
        localAudioService: gh<_i438.LocalAudioService>(),
      ),
    );
    gh.lazySingleton<_i942.PinnedAlbumIDsManager>(
      () => _i942.PinnedAlbumIDsManager(
        localAudioService: gh<_i438.LocalAudioService>(),
      ),
    );
    gh.factoryCachedParam<_i160.FindAlbumManager, int, dynamic>(
      (albumId, _) => _i160.FindAlbumManager(
        albumId: albumId,
        localAudioManager: gh<_i688.LocalAudioManager>(),
      ),
    );
    gh.factoryParam<_i548.FindAlbumNameManager, int, dynamic>(
      (albumId, _) => _i548.FindAlbumNameManager.create(
        albumId: albumId,
        localAudioManager: gh<_i688.LocalAudioManager>(),
      ),
    );
    gh.factoryParam<_i234.FindArtistOfAlbumManager, int, dynamic>(
      (albumId, _) => _i234.FindArtistOfAlbumManager.create(
        albumId: albumId,
        localAudioManager: gh<_i688.LocalAudioManager>(),
      ),
    );
    gh.factoryCached<_i897.FindAllTracksManager>(
      () => _i897.FindAllTracksManager(gh<_i688.LocalAudioManager>()),
    );
    gh.lazySingleton<_i807.SearchManager>(
      () => _i807.SearchManager(
        radioService: gh<_i811.RadioService>(),
        podcastService: gh<_i721.PodcastService>(),
        localAudioService: gh<_i438.LocalAudioService>(),
        settingsService: gh<_i763.SettingsService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factoryCachedParam<_i234.AlbumIDsOfArtistManager, String, dynamic>(
      (artist, _) => _i234.AlbumIDsOfArtistManager(
        artist: artist,
        service: gh<_i438.LocalAudioService>(),
      ),
    );
    gh.lazySingleton<_i1028.CustomContentManager>(
      () => _i1028.CustomContentManager(
        externalPathService: gh<_i551.ExternalPathService>(),
        localAudioService: gh<_i438.LocalAudioService>(),
        podcastService: gh<_i721.PodcastService>(),
        radioService: gh<_i811.RadioService>(),
      ),
    );
    gh.factoryCached<_i190.SidebarAudiosManager>(
      () => _i190.SidebarAudiosManager(
        podcastManager: gh<_i351.PodcastManager>(),
        localAudioManager: gh<_i688.LocalAudioManager>(),
        radioManager: gh<_i749.RadioManager>(),
        playerManager: gh<_i444.PlayerManager>(),
      ),
    );
    gh.factoryParam<_i305.PlaylistManager, String, dynamic>(
      (playlistId, _) => _i305.PlaylistManager.create(
        playlistId: playlistId,
        localAudioManager: gh<_i688.LocalAudioManager>(),
      ),
    );
    gh.factoryCached<_i803.ImportExternalPlaylistManager>(
      () => _i803.ImportExternalPlaylistManager(
        localAudioManager: gh<_i688.LocalAudioManager>(),
      ),
    );
    gh.lazySingleton<_i803.PlaylistIDsManager>(
      () => _i803.PlaylistIDsManager(
        localAudioManager: gh<_i688.LocalAudioManager>(),
      ),
    );
    return this;
  }
}

class _$DioModule extends _i1039.DioModule {}

class _$GithubModule extends _i207.GithubModule {}

class _$LocalNotifierModule extends _i8.LocalNotifierModule {}

class _$MediaKitModule extends _i94.MediaKitModule {}

class _$PackageInfoModule extends _i855.PackageInfoModule {}

class _$SharedPreferencesModule extends _i357.SharedPreferencesModule {}

class _$WindowManagerModule extends _i271.WindowManagerModule {}

class _$DatabaseModule extends _i440.DatabaseModule {}

class _$AudioServiceModule extends _i739.AudioServiceModule {}
