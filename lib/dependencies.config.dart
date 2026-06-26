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
import 'common/manager/retry_manager.dart' as _i569;
import 'common/persistence/database.dart' as _i115;
import 'custom_content/manager/custom_content_manager.dart' as _i925;
import 'expose/manager/expose_manager.dart' as _i960;
import 'expose/service/expose_service.dart' as _i313;
import 'expose/service/lastfm_service.dart' as _i61;
import 'expose/service/listenbrainz_service.dart' as _i821;
import 'external_path/service/external_path_service.dart' as _i415;
import 'local_audio/manager/album_ids_of_artist_manager.dart' as _i483;
import 'local_audio/manager/album_ids_of_genre_manager.dart' as _i475;
import 'local_audio/manager/change_local_meta_data_manager.dart' as _i978;
import 'local_audio/manager/find_album_manager.dart' as _i830;
import 'local_audio/manager/find_album_name_manager.dart' as _i424;
import 'local_audio/manager/find_all_album_i_ds_manager.dart' as _i773;
import 'local_audio/manager/find_all_artists_manager.dart' as _i581;
import 'local_audio/manager/find_all_genres_manager.dart' as _i429;
import 'local_audio/manager/find_all_tracks_manager.dart' as _i178;
import 'local_audio/manager/find_artist_of_album_manager.dart' as _i88;
import 'local_audio/manager/find_titles_of_artist_manager.dart' as _i665;
import 'local_audio/manager/liked_audios_manager.dart' as _i372;
import 'local_audio/manager/local_audio_manager.dart' as _i76;
import 'local_audio/manager/local_cover_manager.dart' as _i612;
import 'local_audio/manager/pinned_album_ids_manager.dart' as _i1030;
import 'local_audio/manager/playlist_ids_manager.dart' as _i924;
import 'local_audio/manager/playlist_manager.dart' as _i438;
import 'local_audio/persistence/local_audio_dao.dart' as _i688;
import 'local_audio/service/local_audio_service.dart' as _i985;
import 'local_audio/service/local_cover_service.dart' as _i582;
import 'lyrics/lyrics_manager.dart' as _i23;
import 'lyrics/lyrics_service.dart' as _i546;
import 'notifications/notifications_service.dart' as _i57;
import 'player/manager/mpv_metadata_manager.dart' as _i507;
import 'player/manager/player_manager.dart' as _i95;
import 'player/persistence/player_dao.dart' as _i443;
import 'player/service/player_service.dart' as _i456;
import 'podcasts/manager/download_manager.dart' as _i167;
import 'podcasts/manager/episodes_manager.dart' as _i776;
import 'podcasts/manager/podcast_clean_manager.dart' as _i599;
import 'podcasts/manager/podcast_feeds_with_downloads_manager.dart' as _i399;
import 'podcasts/manager/podcast_genre_manager.dart' as _i990;
import 'podcasts/manager/podcast_manager.dart' as _i819;
import 'podcasts/manager/podcast_short_info_manager.dart' as _i212;
import 'podcasts/manager/podcast_updates_manager.dart' as _i851;
import 'podcasts/manager/subscribed_podcasts_manager.dart' as _i1055;
import 'podcasts/persistence/podcast_dao.dart' as _i597;
import 'podcasts/service/download_service.dart' as _i881;
import 'podcasts/service/podcast_service.dart' as _i529;
import 'radio/manager/online_art_manager.dart' as _i224;
import 'radio/manager/radio_fav_tag_manager.dart' as _i604;
import 'radio/manager/radio_load_tags_manager.dart' as _i645;
import 'radio/manager/radio_manager.dart' as _i443;
import 'radio/manager/radio_star_station_manager.dart' as _i309;
import 'radio/manager/station_manager.dart' as _i117;
import 'radio/persistence/radio_dao.dart' as _i414;
import 'radio/service/online_art_service.dart' as _i852;
import 'radio/service/radio_service.dart' as _i506;
import 'search/manager/search_manager.dart' as _i354;
import 'settings/manager/settings_manager.dart' as _i964;
import 'settings/manager/wipe_manager.dart' as _i237;
import 'settings/service/settings_service.dart' as _i862;
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
    gh.lazySingleton<_i415.ExternalPathService>(
      () => const _i415.ExternalPathService(),
    );
    gh.lazySingleton<_i546.LocalLyricsService>(
      () => _i546.LocalLyricsService(),
    );
    gh.lazySingleton<_i1009.LicenseStore>(() => _i1009.LicenseStore());
    gh.lazySingleton<_i115.Database>(() => databaseModule.database);
    gh.lazySingleton<_i852.OnlineArtService>(
      () => _i852.OnlineArtService(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i224.OnlineArtManager>(
      () => _i224.OnlineArtManager(
        onlineArtService: gh<_i852.OnlineArtService>(),
      ),
      dispose: (i) => i.dispose(),
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
    gh.singleton<_i506.RadioService>(
      () => _i506.RadioService(dao: gh<_i414.RadioDao>()),
    );
    gh.lazySingleton<_i688.LocalAudioDao>(
      () => _i688.LocalAudioDao(database: gh<_i115.Database>()),
    );
    gh.factoryCached<_i443.RadioManager>(
      () => _i443.RadioManager(radioService: gh<_i506.RadioService>()),
    );
    gh.lazySingleton<_i862.SettingsService>(
      () => _i862.SettingsService(
        sharedPreferences: gh<_i460.SharedPreferences>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factoryParam<_i569.RetryManager, _i327.RetryCapsule, dynamic>(
      (capsule, _) => _i569.RetryManager.create(capsule: capsule),
    );
    gh.lazySingleton<_i57.NotificationsService>(
      () => _i57.NotificationsService(localNotifier: gh<_i526.LocalNotifier>()),
    );
    gh.lazySingleton<_i582.LocalCoverService>(
      () => _i582.LocalCoverService(dao: gh<_i688.LocalAudioDao>()),
    );
    gh.factoryCached<_i604.RadioFavTagManager>(
      () => _i604.RadioFavTagManager(radioManager: gh<_i443.RadioManager>()),
    );
    gh.factoryCached<_i309.RadioStarStationManager>(
      () =>
          _i309.RadioStarStationManager(radioManager: gh<_i443.RadioManager>()),
    );
    gh.lazySingleton<_i645.RadioLoadTagsManager>(
      () => _i645.RadioLoadTagsManager(radioManager: gh<_i443.RadioManager>()),
    );
    gh.lazySingleton<_i546.OnlineLyricsService>(
      () => _i546.OnlineLyricsService(
        dio: gh<_i361.Dio>(),
        localAudioDao: gh<_i688.LocalAudioDao>(),
      ),
    );
    gh.factoryCached<_i612.LocalCoverManager>(
      () => _i612.LocalCoverManager(
        localCoverService: gh<_i582.LocalCoverService>(),
      ),
    );
    gh.factoryCached<_i23.LyricsManager>(
      () => _i23.LyricsManager(
        localLyricsService: gh<_i546.LocalLyricsService>(),
        onlineLyricsService: gh<_i546.OnlineLyricsService>(),
      ),
    );
    gh.lazySingleton<_i881.DownloadService>(
      () => _i881.DownloadService(
        externalPathService: gh<_i415.ExternalPathService>(),
        settingsService: gh<_i862.SettingsService>(),
        dio: gh<_i361.Dio>(),
      ),
    );
    gh.lazySingleton<_i61.LastfmService>(
      () => _i61.LastfmService(settingsService: gh<_i862.SettingsService>()),
    );
    gh.lazySingleton<_i821.ListenBrainzService>(
      () => _i821.ListenBrainzService(
        settingsService: gh<_i862.SettingsService>(),
      ),
    );
    gh.factoryParam<_i117.StationManager, String, dynamic>(
      (uuid, _) => _i117.StationManager.create(
        uuid: uuid,
        radioManager: gh<_i443.RadioManager>(),
      ),
    );
    gh.lazySingleton<_i313.ExposeService>(
      () => _i313.ExposeService(
        lastFmService: gh<_i61.LastfmService>(),
        listenBrainzService: gh<_i821.ListenBrainzService>(),
      ),
    );
    gh.lazySingleton<_i529.PodcastService>(
      () => _i529.PodcastService(
        settingsService: gh<_i862.SettingsService>(),
        dao: gh<_i597.PodcastDao>(),
      ),
    );
    await gh.singletonAsync<_i456.PlayerService>(
      () {
        final i = _i456.PlayerService(
          controller: gh<_i150.VideoController>(),
          exposeService: gh<_i313.ExposeService>(),
          localCoverService: gh<_i582.LocalCoverService>(),
          podcastService: gh<_i529.PodcastService>(),
          dao: gh<_i443.PlayerDao>(),
        );
        return i.init().then((_) => i);
      },
      preResolve: true,
      dispose: (i) => i.dispose(),
    );
    gh.factoryCachedParam<_i776.EpisodesManager, String, dynamic>(
      (feedUrl, _) => _i776.EpisodesManager(
        feedUrl: feedUrl,
        podcastService: gh<_i529.PodcastService>(),
      ),
    );
    gh.factoryCachedParam<_i990.PodcastGenreManager, String, dynamic>(
      (feedUrl, _) => _i990.PodcastGenreManager(
        feedUrl: feedUrl,
        podcastService: gh<_i529.PodcastService>(),
      ),
    );
    gh.factoryCached<_i599.PodcastCleanManager>(
      () => _i599.PodcastCleanManager(gh<_i529.PodcastService>()),
    );
    gh.factoryCached<_i960.ExposeManager>(
      () => _i960.ExposeManager(exposeService: gh<_i313.ExposeService>()),
    );
    gh.lazySingleton<_i985.LocalAudioService>(
      () => _i985.LocalAudioService(
        localCoverService: gh<_i582.LocalCoverService>(),
        settingsService: gh<_i862.SettingsService>(),
        localAudioDao: gh<_i688.LocalAudioDao>(),
      ),
    );
    gh.factoryCached<_i990.PodcastLoadGenresManager>(
      () => _i990.PodcastLoadGenresManager(
        podcastService: gh<_i529.PodcastService>(),
      ),
    );
    gh.factoryCached<_i819.PodcastManager>(
      () => _i819.PodcastManager(podcastService: gh<_i529.PodcastService>()),
    );
    gh.factoryCached<_i851.PodcastUpdatesManager>(
      () => _i851.PodcastUpdatesManager(
        podcastService: gh<_i529.PodcastService>(),
      ),
    );
    gh.factoryCached<_i925.CustomContentManager>(
      () => _i925.CustomContentManager(
        externalPathService: gh<_i415.ExternalPathService>(),
        localAudioService: gh<_i985.LocalAudioService>(),
        podcastService: gh<_i529.PodcastService>(),
        radioService: gh<_i506.RadioService>(),
      ),
    );
    gh.factoryCachedParam<_i475.AlbumIDsOfGenreManager, String, dynamic>(
      (genre, _) => _i475.AlbumIDsOfGenreManager(
        genre: genre,
        service: gh<_i985.LocalAudioService>(),
      ),
    );
    await gh.factoryAsync<_i739.AudioServiceHandler>(
      () => audioServiceModule.audioServiceHandler(
        gh<_i456.PlayerService>(),
        gh<_i740.WindowManager>(),
      ),
      preResolve: true,
    );
    await gh.singletonAsync<_i507.MpvMetadataManager>(
      () {
        final i = _i507.MpvMetadataManager(
          playerService: gh<_i456.PlayerService>(),
          onlineArtService: gh<_i852.OnlineArtService>(),
          exposeService: gh<_i313.ExposeService>(),
          settingsService: gh<_i862.SettingsService>(),
          lyricsManager: gh<_i23.LyricsManager>(),
        );
        return i.init().then((_) => i);
      },
      preResolve: true,
      dispose: (i) => i.dispose(),
    );
    gh.factoryParam<_i212.PodcastShortInfoManager, String, dynamic>(
      (feedUrl, _) => _i212.PodcastShortInfoManager.create(
        feedUrl: feedUrl,
        podcastManager: gh<_i819.PodcastManager>(),
      ),
    );
    gh.factoryCached<_i773.FindAllAlbumIDsManager>(
      () => _i773.FindAllAlbumIDsManager(gh<_i985.LocalAudioService>()),
    );
    gh.factoryCached<_i581.FindAllArtistsManager>(
      () => _i581.FindAllArtistsManager(gh<_i985.LocalAudioService>()),
    );
    gh.factoryCached<_i429.FindAllGenresManager>(
      () => _i429.FindAllGenresManager(gh<_i985.LocalAudioService>()),
    );
    gh.factoryCached<_i372.LikedAudiosManager>(
      () => _i372.LikedAudiosManager(gh<_i985.LocalAudioService>()),
    );
    gh.factoryCachedParam<_i483.AlbumIDsOfArtistManager, String, dynamic>(
      (artist, _) => _i483.AlbumIDsOfArtistManager(
        artist: artist,
        service: gh<_i985.LocalAudioService>(),
      ),
    );
    gh.factoryCachedParam<
      _i978.ChangeLocalMetaDataManager,
      _i537.Audio,
      dynamic
    >(
      (audio, _) => _i978.ChangeLocalMetaDataManager(
        audio: audio,
        localAudioService: gh<_i985.LocalAudioService>(),
      ),
    );
    gh.lazySingleton<_i167.DownloadManager>(
      () => _i167.DownloadManager(
        podcastService: gh<_i529.PodcastService>(),
        downloadService: gh<_i881.DownloadService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i971.RoutingManager>(
      () => _i971.RoutingManager(
        podcastService: gh<_i529.PodcastService>(),
        localAudioService: gh<_i985.LocalAudioService>(),
        radioService: gh<_i506.RadioService>(),
        settingsService: gh<_i862.SettingsService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i95.PlayerManager>(
      () => _i95.PlayerManager(service: gh<_i456.PlayerService>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i369.AppManager>(
      () => _i369.AppManager(
        packageInfo: gh<_i655.PackageInfo>(),
        settingsService: gh<_i862.SettingsService>(),
        gitHub: gh<_i535.GitHub>(),
        localAudioService: gh<_i985.LocalAudioService>(),
      ),
    );
    gh.lazySingleton<_i964.SettingsManager>(
      () => _i964.SettingsManager(
        service: gh<_i862.SettingsService>(),
        podcastService: gh<_i529.PodcastService>(),
        localAudioService: gh<_i985.LocalAudioService>(),
        radioService: gh<_i506.RadioService>(),
        playerService: gh<_i456.PlayerService>(),
      ),
    );
    await gh.singletonAsync<_i517.WindowSizeToSettingsListener>(() {
      final i = _i517.WindowSizeToSettingsListener(
        sharedPreferences: gh<_i460.SharedPreferences>(),
        playerService: gh<_i456.PlayerService>(),
        windowManager: gh<_i740.WindowManager>(),
      );
      return i.init().then((_) => i);
    }, preResolve: true);
    gh.lazySingleton<_i76.LocalAudioManager>(
      () => _i76.LocalAudioManager(
        localAudioService: gh<_i985.LocalAudioService>(),
      ),
    );
    gh.factoryCached<_i354.SearchManager>(
      () => _i354.SearchManager(
        radioManager: gh<_i443.RadioManager>(),
        podcastService: gh<_i529.PodcastService>(),
        localAudioService: gh<_i985.LocalAudioService>(),
        settingsService: gh<_i862.SettingsService>(),
      ),
    );
    gh.lazySingleton<_i1055.SubscribedPodcastsManager>(
      () => _i1055.SubscribedPodcastsManager(
        podcastManager: gh<_i819.PodcastManager>(),
      ),
    );
    gh.factoryCached<_i399.PodcastFeedsWithDownloadsManager>(
      () => _i399.PodcastFeedsWithDownloadsManager(
        podcastManager: gh<_i819.PodcastManager>(),
      ),
    );
    gh.factoryCached<_i1030.PinnedAlbumIDsManager>(
      () => _i1030.PinnedAlbumIDsManager(
        localAudioManager: gh<_i76.LocalAudioManager>(),
      ),
    );
    gh.factoryCached<_i924.ImportExternalPlaylistManager>(
      () => _i924.ImportExternalPlaylistManager(
        localAudioManager: gh<_i76.LocalAudioManager>(),
      ),
    );
    gh.lazySingleton<_i924.PlaylistIDsManager>(
      () => _i924.PlaylistIDsManager(
        localAudioManager: gh<_i76.LocalAudioManager>(),
      ),
    );
    gh.factoryParam<_i665.FindTitlesOfArtistManager, String, dynamic>(
      (artist, _) => _i665.FindTitlesOfArtistManager.create(
        artist: artist,
        localAudioManager: gh<_i76.LocalAudioManager>(),
      ),
    );
    gh.factoryCachedParam<_i830.FindAlbumManager, int, dynamic>(
      (albumId, _) => _i830.FindAlbumManager(
        albumId: albumId,
        localAudioManager: gh<_i76.LocalAudioManager>(),
      ),
    );
    gh.factoryParam<_i424.FindAlbumNameManager, int, dynamic>(
      (albumId, _) => _i424.FindAlbumNameManager.create(
        albumId: albumId,
        localAudioManager: gh<_i76.LocalAudioManager>(),
      ),
    );
    gh.factoryParam<_i88.FindArtistOfAlbumManager, int, dynamic>(
      (albumId, _) => _i88.FindArtistOfAlbumManager.create(
        albumId: albumId,
        localAudioManager: gh<_i76.LocalAudioManager>(),
      ),
    );
    gh.factoryCached<_i237.WipeManager>(
      () => _i237.WipeManager(
        settingsManager: gh<_i964.SettingsManager>(),
        podcastManager: gh<_i819.PodcastManager>(),
        radioManager: gh<_i443.RadioManager>(),
        localAudioManager: gh<_i76.LocalAudioManager>(),
        playerManager: gh<_i95.PlayerManager>(),
        database: gh<_i115.Database>(),
      ),
    );
    gh.factoryCached<_i178.FindAllTracksManager>(
      () => _i178.FindAllTracksManager(gh<_i76.LocalAudioManager>()),
    );
    gh.factoryParam<_i438.PlaylistManager, String, dynamic>(
      (playlistId, _) => _i438.PlaylistManager.create(
        playlistId: playlistId,
        localAudioManager: gh<_i76.LocalAudioManager>(),
      ),
    );
    gh.factoryCached<_i190.SidebarAudiosManager>(
      () => _i190.SidebarAudiosManager(
        podcastService: gh<_i529.PodcastService>(),
        podcastUpdatesManager: gh<_i851.PodcastUpdatesManager>(),
        playlistIDsManager: gh<_i924.PlaylistIDsManager>(),
        radioManager: gh<_i443.RadioManager>(),
        podcastToggleManager: gh<_i1055.SubscribedPodcastsManager>(),
        playerManager: gh<_i95.PlayerManager>(),
        radioStarStationManager: gh<_i309.RadioStarStationManager>(),
        pinnedAlbumIDsManager: gh<_i1030.PinnedAlbumIDsManager>(),
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
